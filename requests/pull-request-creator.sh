#!/bin/bash

# Absolute Pfade ermitteln
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/e.py"
F_PYTHON_SCRIPT="$SCRIPT_DIR/f.py"

TARGET_DIR="${1:-.}"
cd "$TARGET_DIR" || exit 1

# Globale Variablen
WAS_VERSION_BUMPED=false
CURRENT_VERSION_CODE=""

# Globale Arrays für Changelog-Kategorisierung
declare -a DE_ADDED EN_ADDED
declare -a DE_UPDATED EN_UPDATED
declare -a DE_FIXED EN_FIXED
declare -a DE_IMPROVED EN_IMPROVED

# --- Helper-Funktion zum sauberen Trimmen von Strings ---
trim_string() {
    local var="$1"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

# --- Helper-Funktion: Array als kommagetrennte Zeile ausgeben ---
join_array_with_comma() {
    local -n arr=$1
    local result=""
    for item in "${arr[@]}"; do
        if [ -z "$result" ]; then
            result="$item"
        else
            result+=", $item"
        fi
    done
    echo "$result"
}

# --- Python-Installation & Umgebung prüfen ---
ensure_python() {
    if ! command -v python3 &> /dev/null; then
        echo "--> Python3 was not found. Attempting automatic installation..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y python3 python3-pip python3-pil curl
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y python3 python3-pip python3-pillow curl
        elif command -v brew &> /dev/null; then
            brew install python3 pillow curl
        else
            echo "Error: Package manager not recognized. Please install Python3 manually."
            exit 1
        fi
    fi
}

# --- Gradle-Installation prüfen & ggf. via Snap/SDKMAN/Brew installieren ---
ensure_gradle() {
    if command -v gradle &> /dev/null; then
        return 0
    fi

    echo "--> System Gradle was not found. Attempting automatic installation..."
    if command -v snap &> /dev/null; then
        echo "--> Installing Gradle via Snap..."
        sudo snap install gradle --classic
    elif command -v sdk &> /dev/null; then
        echo "--> Installing Gradle via SDKMAN!..."
        sdk install gradle
    elif command -v brew &> /dev/null; then
        echo "--> Installing Gradle via Brew..."
        brew install gradle
    elif command -v apt-get &> /dev/null; then
        echo "--> Installing Gradle via apt..."
        sudo apt-get update && sudo apt-get install -y gradle
    elif command -v dnf &> /dev/null; then
        echo "--> Installing Gradle via dnf..."
        sudo dnf install -y gradle
    elif command -v choco &> /dev/null; then
        echo "--> Installing Gradle via choco..."
        choco install gradle
    else
        echo "Error: No suitable package manager found for Gradle."
        echo "Please install Gradle manually (e.g., via Snap: 'sudo snap install gradle --classic')."
        return 1
    fi
}

# --- Gradle Task finishXMLs ausführen ---
run_gradle_finish_xmls() {
    echo -e "\n--> Running Gradle task 'finishXMLs'..."
    
    local root_dir
    root_dir="$(cd "$SCRIPT_DIR/.." && pwd)"

    (
        cd "$root_dir" || exit 1
        
        if [ -f "./gradlew" ]; then
            chmod +x ./gradlew 2>/dev/null
            ./gradlew finishXMLs
        else
            ensure_gradle
            if command -v gradle &> /dev/null; then
                gradle finishXMLs
            else
                echo "  [!] ERROR: Neither ./gradlew nor 'gradle' is available."
                return 1
            fi
        fi
    )

    if [ $? -eq 0 ]; then
        echo "  [✓] Gradle task 'finishXMLs' executed successfully."
    else
        echo "  [!] ERROR: Execution of Gradle task 'finishXMLs' failed!"
    fi
}

# --- Klarnamen eines Icons via f.py <ID> ermitteln ---
get_icon_display_name() {
    local target_folder="$1"
    local icon_id="$2"
    local display_name=""

    if [ -f "$F_PYTHON_SCRIPT" ] && [ -n "$icon_id" ]; then
        local f_single_output
        f_single_output=$(
            cd "$target_folder" || exit 1
            python3 "$F_PYTHON_SCRIPT" "$icon_id" 2>/dev/null
        )

        display_name=$(echo "$f_single_output" | grep -iE '^(Changelog|Name):' | head -n 1 | cut -d':' -f2-)
        display_name=$(trim_string "$display_name")

        if [ -z "$display_name" ]; then
            if [[ "$f_single_output" =~ name=\"([^\"]+)\" ]]; then
                display_name="${BASH_REMATCH[1]}"
            fi
        fi
    fi

    if [ -z "$display_name" ]; then
        display_name="$icon_id"
    fi

    echo "$display_name"
}

# --- Eindeutigen 32-stelligen Hex-Namen generieren ---
generate_unique_hex_name() {
    local target_folder="$1"
    local new_hex=""
    local is_unique=false

    while [ "$is_unique" = false ]; do
        local raw_hex
        raw_hex=$(head /dev/urandom | tr -dc 'a-f0-9' | head -c 32)
        new_hex="_${raw_hex}"
        
        local check_output
        check_output=$(
            cd "$target_folder" || exit 1
            python3 "$PYTHON_SCRIPT"
        )
        
        if ! echo "$check_output" | grep -q "$new_hex"; then
            is_unique=true
        fi
    done

    echo "$new_hex"
}

# --- PNG-Dateien bereinigen (Sanitization) ---
sanitize_png_names() {
    local target_folder="$1"
    
    for png_path in "$target_folder"/*.png; do
        [ -e "$png_path" ] || continue
        
        local filename=$(basename "$png_path")
        local name="${filename%.png}"
        
        if [[ "$name" =~ [^a-z0-9_] ]] || [[ "$name" =~ ^[0-9] ]]; then
            echo "--> Invalid characters or leading number detected in filename: '$filename'"
            
            local new_hex_name
            new_hex_name=$(generate_unique_hex_name "$target_folder")
            
            mv "$png_path" "$target_folder/$new_hex_name.png"
            echo "  [✓] Automatic renaming: '$filename' -> '$new_hex_name.png'"
            
            local xml_files=("$target_folder/appfilter.xml" "$target_folder/theme_resources.xml")
            for xml in "${xml_files[@]}"; do
                if [ -f "$xml" ]; then
                    sed -i "s/=\"${name}\"/=\"${new_hex_name}\"/g" "$xml"
                    echo "  [✓] XML updated: $(basename "$xml")"
                fi
            done
        fi
    done
}

# --- System-Ordner öffnen Helper ---
open_directory() {
    local dir_path="$1"
    if [ -d "$dir_path" ]; then
        if command -v xdg-open &> /dev/null; then
            xdg-open "$dir_path" &> /dev/null &
        elif command -v open &> /dev/null; then
            open "$dir_path" &> /dev/null &
        fi
    fi
}

# --- Interaktives Icon-Mapping ---
map_existing_icons() {
    local target_folder="$1"
    local drawable_dir="../app/src/main/res/drawable-nodpi"

    while true; do
        echo -e "\n=== [Optional] Mapping icons to existing icons ==="
        
        local png_files=()
        for png in "$target_folder"/*.png; do
            [ -e "$png" ] || continue
            png_files+=("$(basename "$png" .png)")
        done

        if [ ${#png_files[@]} -eq 0 ]; then
            echo "No PNG files present in folder."
            break
        fi

        local map_counter=1
        declare -A MAP_INDEX
        for icon in "${png_files[@]}"; do
            echo "$map_counter) $icon"
            MAP_INDEX[$map_counter]="$icon"
            ((map_counter++))
        done

        echo ""
        read -p "Select number to map (Just enter = Continue): " map_choice

        if [ -z "$map_choice" ]; then
            echo "-> Mapping finished."
            break
        fi

        local selected_icon="${MAP_INDEX[$map_choice]}"

        if [ -n "$selected_icon" ]; then
            echo -e "\n--> Please find the matching id in the opened drawable-nodpi folder."
            
            if [ -d "$drawable_dir" ]; then
                open_directory "$drawable_dir"
            else
                echo "[!] Note: Folder '$drawable_dir' was not found locally."
            fi

            read -p "Enter new ID for '$selected_icon': " new_mapped_name

            if [ -n "$new_mapped_name" ]; then
                local old_png="$target_folder/$selected_icon.png"
                local new_png="$target_folder/$new_mapped_name.png"
                
                if [ -f "$old_png" ]; then
                    mv "$old_png" "$new_png"
                    echo "  [✓] PNG renamed: '$selected_icon.png' -> '$new_png'"
                fi

                local xml_files=("$target_folder/appfilter.xml" "$target_folder/theme_resources.xml")
                for xml in "${xml_files[@]}"; do
                    if [ -f "$xml" ]; then
                        sed -i "s/=\"${selected_icon}\"/=\"${new_mapped_name}\"/g" "$xml"
                        echo "  [✓] XML updated: $(basename "$xml")"
                    fi
                done
            else
                echo "-> No input received. Element left unchanged."
            fi
        else
            echo "Invalid selection!"
        fi
    done
}

# --- Helper zum Aktualisieren/Erweitern von .txt Changelogs ---
update_single_txt_changelog() {
    local file_path="$1"
    local prefix="$2"
    local -n items_arr=$3

    [ ${#items_arr[@]} -eq 0 ] && return 0

    local new_items_str
    new_items_str=$(join_array_with_comma items_arr)

    if [ -f "$file_path" ] && grep -q "^${prefix} " "$file_path"; then
        local existing_line
        existing_line=$(grep "^${prefix} " "$file_path")
        local updated_line="${existing_line}, ${new_items_str}"
        sed -i "s|^${prefix} .*|${updated_line}|" "$file_path"
    else
        echo "${prefix} ${new_items_str}" >> "$file_path"
    fi
}

# --- Metadaten Changelog-Dateien & changelog.xml schreiben/erweitern ---
write_metadata_changelogs() {
    local version_code="$1"
    local version_name="$2"
    local de_dir="../metadata/de-DE/changelogs"
    local en_dir="../metadata/en-US/changelogs"
    local xml_changelog_file="../app/src/main/res/values/changelog.xml"

    mkdir -p "$de_dir" "$en_dir"

    local de_file="$de_dir/${version_code}.txt"
    local en_file="$en_dir/${version_code}.txt"

    update_single_txt_changelog "$de_file" "Hinzugefügt" DE_ADDED
    update_single_txt_changelog "$de_file" "Aktualisiert" DE_UPDATED
    update_single_txt_changelog "$de_file" "Wiederhergestellt" DE_FIXED
    update_single_txt_changelog "$de_file" "Verbessert" DE_IMPROVED
    echo "  [✓] Processed changelog (de-DE) in '$de_file'."

    update_single_txt_changelog "$en_file" "Added" EN_ADDED
    update_single_txt_changelog "$en_file" "Updated" EN_UPDATED
    update_single_txt_changelog "$en_file" "Fixed" EN_FIXED
    update_single_txt_changelog "$en_file" "Improved" EN_IMPROVED
    echo "  [✓] Processed changelog (en-US) in '$en_file'."

    if [ -f "$xml_changelog_file" ]; then
        echo -e "\n--> Updating XML changelog at '$xml_changelog_file'..."
        local today_date
        today_date=$(date +"%d.%m.%Y")

        python3 - "$xml_changelog_file" "$version_name" "$today_date" \
                 "$(join_array_with_comma EN_ADDED)" \
                 "$(join_array_with_comma EN_UPDATED)" \
                 "$(join_array_with_comma EN_FIXED)" \
                 "$(join_array_with_comma EN_IMPROVED)" << 'EOF'
import sys
import re

xml_path = sys.argv[1]
version_name = sys.argv[2]
today_date = sys.argv[3]
added = sys.argv[4]
updated = sys.argv[5]
fixed = sys.argv[6]
improved = sys.argv[7]

with open(xml_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(
    r'(<string name="changelog_date">)[^<]+(</string>)',
    rf'\g<1>{today_date}\g<2>',
    content
)

version_tag = f"<item>{version_name}:</item>"

updates = [
    ("Added", added),
    ("Updated", updated),
    ("Fixed", fixed),
    ("Improved", improved)
]

if version_tag in content:
    for category, items in updates:
        if not items:
            continue
        
        pattern = rf'({re.escape(version_tag)}[\s\S]*?<item>{category}\s+)([^<]+)(</item>)'
        match = re.search(pattern, content)
        
        if match:
            content = re.sub(
                pattern,
                rf'\g<1>\g<2>, {items}\g<3>',
                content,
                count=1
            )
        else:
            new_line = f"        <item>{category} {items}</item>\n"
            content = content.replace(version_tag, f"{version_tag}\n{new_line}", 1)
            
    print(f"  [✓] Expanded existing entry for v{version_name} in changelog.xml.")

else:
    new_version_lines = [f"        <item>{version_name}:</item>"]
    for category, items in updates:
        if items:
            new_version_lines.append(f"        <item>{category} {items}</item>")
    
    insert_block = "\n" + "\n".join(new_version_lines) + "\n"
    content = re.sub(
        r'(<string-array name="changelog">)',
        rf'\1{insert_block}',
        content,
        count=1
    )
    print(f"  [✓] Created new entry for v{version_name} in changelog.xml.")

with open(xml_path, 'w', encoding='utf-8') as f:
    f.write(content)

EOF
    else
        echo "  [!] Warning: '$xml_changelog_file' not found!"
    fi
}

# --- Gradle, ThemeInfo & ThemeCfg verwalten ---
manage_gradle_version_and_changelog() {
    local target_folder="$1"
    local gradle_file="../app/build.gradle"
    local themeinfo_file="../app/src/main/res/xml/themeinfo.xml"
    local themecfg_file="../app/src/main/res/xml/themecfg.xml"

    WAS_VERSION_BUMPED=false

    if [ ! -f "$gradle_file" ]; then
        echo "[!] Error: Gradle file '$gradle_file' not found."
        return 1
    fi

    echo -e "\n=== PROCESSING VERSION & CHANGELOG ==="

    local version_code
    local version_name
    version_code=$(grep -E 'versionCode\s+[0-9]+' "$gradle_file" | awk '{print $2}')
    version_name=$(grep -E "versionName\s+['\"]" "$gradle_file" | sed -E "s/.*versionName\s+['\"]([^'\"]+)['\"].*/\1/")

    echo "Found Version Code : $version_code"
    echo "Found Version Name : $version_name"

    local github_url="https://github.com/MiepHD/cuscon/releases/tag/v${version_name}"
    echo "Checking GitHub Release status: $github_url"

    local http_code
    http_code=$(curl -o /dev/null -s -w "%{http_code}" -L "$github_url")

    if [ "$http_code" -eq 200 ]; then
        echo "--> Release v$version_name already exists on GitHub (HTTP 200). Increasing version..."
        
        WAS_VERSION_BUMPED=true

        local new_version_code=$((version_code + 1))
        local new_version_name
        new_version_name=$(python3 - "$version_name" << 'EOF'
import sys

v_str = sys.argv[1]
parts = [int(p) for p in v_str.split('.')]

parts[-1] += 1
for i in range(len(parts) - 1, 0, -1):
    if parts[i] >= 10:
        parts[i] = 0
        parts[i-1] += 1

print(".".join(map(str, parts)))
EOF
)

        echo "  [✓] New Version Code : $new_version_code"
        echo "  [✓] New Version Name : $new_version_name"

        sed -i -E "s/(versionCode\s+)[0-9]+/\1$new_version_code/" "$gradle_file"
        sed -i -E "s/(versionName\s+['\"])[^'\"]+(['\"])/\1$new_version_name\2/" "$gradle_file"
        echo "  [✓] build.gradle updated."

        if [ -f "$themeinfo_file" ]; then
            sed -i -E "s/(<versionCode>)[0-9]+(<\/versionCode>)/\1$new_version_code\2/" "$themeinfo_file"
            sed -i -E "s/(<versionName>)[^<]+(<\/versionName>)/\1$new_version_name\2/" "$themeinfo_file"
            echo "  [✓] themeinfo.xml updated."
        fi

        if [ -f "$themecfg_file" ]; then
            sed -i -E "s/(<version>)[0-9]+(<\/version>)/\1$new_version_code\2/" "$themecfg_file"
            echo "  [✓] themecfg.xml updated."
        fi

        version_code="$new_version_code"
        version_name="$new_version_name"
    else
        echo "--> Release v$version_name doesn't exist on Github yet. Keeping current version."
        WAS_VERSION_BUMPED=false
    fi

    CURRENT_VERSION_CODE="$version_code"
    write_metadata_changelogs "$version_code" "$version_name"
}

# --- f.py ausführen und Einträge einfügen ---
process_f_get() {
    local target_folder="$1"
    
    if [ ! -f "$F_PYTHON_SCRIPT" ]; then
        echo "Error: The file 'f.py' could not be found under '$F_PYTHON_SCRIPT'!"
        return 1
    fi
    
    local f_output
    f_output=$(
        cd "$target_folder" || exit 1
        python3 "$F_PYTHON_SCRIPT" -get
    )

    local appfilter_entries=()
    local theme_resources_entries=()
    local drawable_entries=()
    local current_section=""
    local xml_regex="<.*>"

    while IFS= read -r line; do
        local raw_line="$line"
        line=$(trim_string "$line")

        if [[ "$line" =~ ^Appfilter: ]]; then
            current_section="appfilter"; continue
        elif [[ "$line" =~ ^Drawable: ]]; then
            current_section="drawable"; continue
        elif [[ "$line" =~ ^Theme\ Resources: ]]; then
            current_section="theme_resources"; continue
        elif [[ "$line" =~ ^Changelog: ]]; then
            current_section="changelog"; continue
        fi

        if [[ "$current_section" != "changelog" && -n "$line" && "$line" =~ $xml_regex ]]; then
            if [[ "$current_section" == "appfilter" ]]; then
                appfilter_entries+=("$line")
            elif [[ "$current_section" == "theme_resources" ]]; then
                theme_resources_entries+=("$line")
            elif [[ "$current_section" == "drawable" ]]; then
                drawable_entries+=("$line")
            fi
        fi
    done <<< "$f_output"

    local target_appfilter="../app/src/main/res/xml/appfilter.xml"
    local target_theme="../app/src/main/res/xml/theme_resources.xml"
    local target_drawable="../app/src/main/res/xml/drawable.xml"

    insert_xml_entries() {
        local file="$1"
        local search_pattern="$2"
        local insert_after="$3"
        shift 3
        local entries=("$@")

        [ ! -f "$file" ] || [ ${#entries[@]} -eq 0 ] && return 0

        local tmp_file
        tmp_file=$(mktemp)
        local inserted=false

        while IFS= read -r line || [ -n "$line" ]; do
            if [[ "$line" == *"$search_pattern"* ]] && [ "$inserted" = false ]; then
                if [ "$insert_after" = "true" ]; then
                    echo "$line" >> "$tmp_file"
                    for entry in "${entries[@]}"; do echo "    $entry" >> "$tmp_file"; done
                else
                    for entry in "${entries[@]}"; do echo "    $entry" >> "$tmp_file"; done
                    echo "$line" >> "$tmp_file"
                fi
                inserted=true
            else
                echo "$line" >> "$tmp_file"
            fi
        done < "$file"

        if [ "$inserted" = false ]; then
            for entry in "${entries[@]}"; do echo "    $entry" >> "$tmp_file"; done
        fi

        mv "$tmp_file" "$file"
        echo "[✓] ${#entries[@]} Successfully inserted entries into '$(basename "$file")'."
    }

    insert_xml_entries "$target_appfilter" "</resources>" "false" "${appfilter_entries[@]}"
    insert_xml_entries "$target_theme" "</Theme>" "false" "${theme_resources_entries[@]}"

    # --- Bildverarbeitung & Export ---
    process_images "$target_folder"

    # --- Version & Metadata Changelogs ---
    manage_gradle_version_and_changelog "$target_folder"

    # --- Erweiterte Logik für drawable.xml ---
    if [ -f "$target_drawable" ]; then
        echo -e "\n--> Updating '$target_drawable'..."
        
        local all_changed_ids="${PROCESSED_IDS_ARRAY[*]}"
        local all_drawable_lines=""
        for line in "${drawable_entries[@]}"; do
            all_drawable_lines="${all_drawable_lines}${line}"$'\n'
        done

        python3 - "$target_drawable" "$all_changed_ids" "$all_drawable_lines" "$WAS_VERSION_BUMPED" << 'EOF'
import sys
import re

drawable_path = sys.argv[1]
changed_ids = sys.argv[2].split() if len(sys.argv) > 2 and sys.argv[2] else []
drawable_lines_raw = sys.argv[3].strip().split('\n') if len(sys.argv) > 3 and sys.argv[3].strip() else []
was_version_bumped = sys.argv[4].lower() == "true" if len(sys.argv) > 4 else False

id_to_item = {}
for line in drawable_lines_raw:
    line = line.strip()
    if not line:
        continue
    match = re.search(r'drawable="([^"]+)"', line)
    if match:
        icon_id = match.group(1)
        id_to_item[icon_id] = line

with open(drawable_path, 'r', encoding='utf-8') as f:
    content = f.read()

def get_category_title(item_str, icon_id):
    name_match = re.search(r'name="([^"]+)"', item_str)
    if name_match:
        target_str = name_match.group(1).strip()
    else:
        target_str = icon_id[1:] if icon_id.startswith('_') else icon_id

    if not target_str:
        return "#"

    first_char = target_str[0]
    
    if first_char.isdigit():
        return "#"
    elif first_char.isalpha():
        return first_char.upper()
    else:
        return "#"

# 1. New Icons leeren, FALLS die Version erhöht wurde (bevor die neuen reinkommen)
if was_version_bumped:
    content = re.sub(
        r'(<category title="New Icons"\s*/?>)([\s\S]*?)(?=<category title=|\s*</resources>)',
        r'\1\n',
        content,
        count=1
    )
    print("  [✓] Cleared 'New Icons' category (version incremented).")

# 2. New Icons befüllen (Geänderte & Neue Icons einfügen)
for icon_id in changed_ids:
    item_str = id_to_item.get(icon_id, f'<item drawable="{icon_id}"/>')
    
    pattern_exist = rf'(<category title="New Icons"\s*/?>[\s\S]*?)({re.escape(item_str)}|drawable="{re.escape(icon_id)}")(.*?<category)'
    if not re.search(pattern_exist, content):
        cat_pattern = r'(<category title="New Icons"\s*/?>)'
        content = re.sub(cat_pattern, rf'\1\n    {item_str}', content, count=1)

# 3. Neue/Fehlende Icons in ihre Buchstabensektion (#, A-Z) einfügen
for icon_id in changed_ids:
    item_str = id_to_item.get(icon_id, f'<item drawable="{icon_id}"/>')
    clean_id = icon_id[1:] if icon_id.startswith('_') else icon_id
    
    first_letter_cat = re.search(r'<category title="(#|[A-Z])"\s*/?>', content)
    already_in_letters = False
    if first_letter_cat:
        rest_content = content[first_letter_cat.start():]
        if item_str in rest_content or f'drawable="{icon_id}"' in rest_content or f'drawable="{clean_id}"' in rest_content:
            already_in_letters = True
            
    if not already_in_letters:
        target_cat = get_category_title(item_str, icon_id)
        cat_tag = f'<category title="{target_cat}"/>'
        
        if cat_tag in content:
            content = content.replace(cat_tag, f'{cat_tag}\n    {item_str}', 1)
        else:
            new_cat_block = f'    {cat_tag}\n    {item_str}\n'
            content = content.replace('</resources>', f'{new_cat_block}</resources>', 1)

with open(drawable_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("  [✓] 'drawable.xml' updated successfully.")
EOF
    fi

    # --- Gradle finishXMLs ausführen ---
    run_gradle_finish_xmls

    # --- Git-Befehle ausgeben ---
    print_git_commands "$CURRENT_VERSION_CODE"
}

# --- PNGs Resizing & WEBP Konvertierung ---
process_images() {
    local target_folder="$1"
    local dest_dir="../app/src/main/res/drawable-nodpi"

    mkdir -p "$dest_dir"

    local image_files=()
    for img in "$target_folder"/*.png; do
        [ -e "$img" ] || continue
        image_files+=("$img")
    done

    [ ${#image_files[@]} -eq 0 ] && return 0

    echo -e "\n=== EXCLUDE IMAGES FROM EXPORT ==="
    local img_counter=1
    declare -A IMG_INDEX
    for img in "${image_files[@]}"; do
        echo "$img_counter) $(basename "$img")"
        IMG_INDEX[$img_counter]="$img"
        ((img_counter++))
    done

    echo ""
    read -p "Specify image numbers NOT to copy (comma-separated) [Enter = none]: " exclude_input

    declare -A EXCLUDED
    IFS=',' read -ra EXCLUDE_ARRAY <<< "$exclude_input"
    for num in "${EXCLUDE_ARRAY[@]}"; do
        num=$(trim_string "$num")
        [ -n "$num" ] && EXCLUDED["$num"]=1
    done

    echo -e "\n--> Processing images for icon pack..."

    local process_counter=1
    for img in "${image_files[@]}"; do
        if [ "${EXCLUDED[$process_counter]}" == "1" ]; then
            echo "  [-] Skipped (excluded): $(basename "$img")"
            ((process_counter++))
            continue
        fi

        local filename=$(basename "$img")
        local base_name="${filename%.png}"
        local target_webp="$dest_dir/$base_name.webp"

        python3 - "$img" "$target_webp" << 'EOF'
import sys
from PIL import Image

src_path, dest_path = sys.argv[1], sys.argv[2]
try:
    with Image.open(src_path) as img:
        width, height = img.size
        if width != height:
            print(f"  [!] ERROR: '{src_path}' is not square ({width}x{height})! Skipped.")
            sys.exit(1)
        if width != 256 or height != 256:
            img = img.resize((256, 256), Image.Resampling.LANCZOS)
            print(f"  [✓] Scale to 256x256: {src_path}")
        img.save(dest_path, "WEBP", quality=100, alpha_quality=0)
        print(f"  [✓] Created WEBP: {dest_path}")
except Exception as e:
    print(f"  [!] Error while processing '{src_path}': {e}")
    sys.exit(1)
EOF
        ((process_counter++))
    done
    echo -e "\n[✓] Image processing completed."
}

# --- Generierung und Ausgabe der Git Befehle ---
print_git_commands() {
    local version_code="$1"
    
    local current_en_changelog=""
    [ ${#EN_ADDED[@]} -gt 0 ] && current_en_changelog+="Added $(join_array_with_comma EN_ADDED). "
    [ ${#EN_UPDATED[@]} -gt 0 ] && current_en_changelog+="Updated $(join_array_with_comma EN_UPDATED). "
    [ ${#EN_FIXED[@]} -gt 0 ] && current_en_changelog+="Fixed $(join_array_with_comma EN_FIXED). "
    [ ${#EN_IMPROVED[@]} -gt 0 ] && current_en_changelog+="Improved $(join_array_with_comma EN_IMPROVED). "
    
    current_en_changelog=$(trim_string "$current_en_changelog")
    [ -z "$current_en_changelog" ] && current_en_changelog="Updated icons and app resources"

    echo -e "\n======================================================="
    echo "            GIT COMMANDS TO COPY"
    echo "======================================================="
    
    echo -e "\n# 1. Stage changed files:"
    echo "git add app/build.gradle \\"
    echo "        app/src/main/assets/appfilter.xml \\"
    echo "        app/src/main/assets/drawable.xml \\"
    echo "        app/src/main/res/drawable-nodpi/ \\"
    echo "        app/src/main/res/values/changelog.xml \\"
    echo "        app/src/main/res/xml/appfilter.xml \\"
    echo "        app/src/main/res/xml/drawable.xml \\"
    echo "        app/src/main/res/xml/theme_resources.xml \\"
    echo "        app/src/main/res/xml/themeinfo.xml \\"
    echo "        app/src/main/res/xml/themecfg.xml \\"
    echo "        metadata/de-DE/changelogs/${version_code}.txt \\"
    echo "        metadata/en-US/changelogs/${version_code}.txt"

    echo -e "\n# 2. Commit with changelog:"
    echo "git commit -m \"$current_en_changelog\""

    echo -e "\n# 3. Push changes:"
    echo "git push"
    echo -e "=======================================================\n"
}

# --- Task Steuerung ---
run_python_task() {
    local target_folder="$1"
    
    if [ ! -f "$PYTHON_SCRIPT" ]; then
        echo "Error: 'e.py' could not be found under '$PYTHON_SCRIPT'!"
        return 1
    fi

    ensure_python
    sanitize_png_names "$target_folder"

    echo -e "\n--> Opening '$target_folder' ..."
    
    local py_output
    py_output=$(
        cd "$target_folder" || exit 1
        python3 "$PYTHON_SCRIPT"
    )

    local already_added_items=()
    local conflicts_items=()
    local current_section=""

    while IFS= read -r line; do
        line=$(trim_string "$line")
        [ -z "$line" ] && continue

        if [[ "$line" == "Already added:" ]]; then current_section="already_added"; continue; fi
        if [[ "$line" == "Conflicts:" ]]; then current_section="conflicts"; continue; fi

        if [[ "$current_section" == "already_added" ]]; then already_added_items+=("$line"); fi
        if [[ "$current_section" == "conflicts" ]]; then conflicts_items+=("$line"); fi
    done <<< "$py_output"

    DE_ADDED=(); EN_ADDED=()
    DE_UPDATED=(); EN_UPDATED=()
    DE_FIXED=(); EN_FIXED=()
    DE_IMPROVED=(); EN_IMPROVED=()

    declare -A PROCESSED_IDS
    PROCESSED_IDS_ARRAY=()

    # Already Added
    if [ ${#already_added_items[@]} -gt 0 ]; then
        echo "=== [Processing] Already Added ==="
        for item in "${already_added_items[@]}"; do
            local display_name
            display_name=$(get_icon_display_name "$target_folder" "$item")

            echo -e "\nItem: '$item' ($display_name)"
            echo "  1) Delete item from request (delete .png)"
            echo "  2) Replace existing item [Category: Improved]"
            read -p "Select (1/2): " aa_choice
            
            case "$aa_choice" in
                1)
                    local png_file="$target_folder/$item.png"
                    [ -f "$png_file" ] && rm -f "$png_file"
                    DE_FIXED+=("$display_name"); EN_FIXED+=("$display_name")
                    PROCESSED_IDS["$item"]=1; PROCESSED_IDS_ARRAY+=("$item")
                    ;;
                2)
                    DE_IMPROVED+=("$display_name"); EN_IMPROVED+=("$display_name")
                    PROCESSED_IDS["$item"]=1; PROCESSED_IDS_ARRAY+=("$item")
                    ;;
                *) echo "-> Invalid selection. Replacing existing item." ;;
            esac
        done
    fi

    # Conflicts
    if [ ${#conflicts_items[@]} -gt 0 ]; then
        echo -e "\n=== [Processing] Conflicts ==="
        for item in "${conflicts_items[@]}"; do
            local display_name
            display_name=$(get_icon_display_name "$target_folder" "$item")

            echo -e "\nConflict: '$item' ($display_name)"
            echo "  1) Item is an update to an existing one [Category: Updated]"
            echo "  2) Rename item [Category: Added]"
            read -p "Select (1/2): " c_choice
            
            case "$c_choice" in
                1)
                    DE_UPDATED+=("$display_name"); EN_UPDATED+=("$display_name")
                    PROCESSED_IDS["$item"]=1; PROCESSED_IDS_ARRAY+=("$item")
                    ;;
                2)
                    local random_id
                    random_id=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 6)
                    local new_name="${item}_${random_id}"
                    
                    local old_png="$target_folder/$item.png"
                    local new_png="$target_folder/$new_name.png"
                    [ -f "$old_png" ] && mv "$old_png" "$new_png"
                    
                    local xml_files=("$target_folder/appfilter.xml" "$target_folder/theme_resources.xml")
                    for xml in "${xml_files[@]}"; do
                        [ -f "$xml" ] && sed -i "s/=\"${item}\"/=\"${new_name}\"/g" "$xml"
                    done

                    DE_ADDED+=("$display_name"); EN_ADDED+=("$display_name")
                    PROCESSED_IDS["$item"]=1; PROCESSED_IDS["$new_name"]=1
                    PROCESSED_IDS_ARRAY+=("$new_name")
                    ;;
                *) echo "-> Invalid selection. Updating existing one." ;;
            esac
        done
    fi

    map_existing_icons "$target_folder"

    # Restliche Icons
    for png in "$target_folder"/*.png; do
        [ -e "$png" ] || continue
        local id_name=$(basename "$png" .png)

        if [ "${PROCESSED_IDS["$id_name"]}" != "1" ]; then
            local display_name
            display_name=$(get_icon_display_name "$target_folder" "$id_name")
            DE_ADDED+=("$display_name"); EN_ADDED+=("$display_name")
            PROCESSED_IDS["$id_name"]=1; PROCESSED_IDS_ARRAY+=("$id_name")
        fi
    done

    echo -e "\n======================================================="
    echo -e "# Requirements for contributing icons\n- Icons must be outlined in black\n- Icon should be visible on black background\n- dimension of 256x256px\n- should have approximate 15px transparent border\n- The black border should be approximately 6px thick"
    echo "Please edit icons in request directory '$target_folder' now."
    echo "======================================================="
    open_directory "$target_folder"

    echo ""
    read -p "Press [ENTER] when you're finished with editing..."

    while true; do
        read -p "Do you want to proceed and add the icons to the icon pack? (y/n): " confirm
        case "$confirm" in
            [Yy]*)
                echo -e "\n[✓] Process confirmed. Starting utilization of XML entries..."
                process_f_get "$target_folder"
                break
                ;;
            [Nn]*)
                echo -e "\n[!] Operation canceled. Icons were not added."
                break
                ;;
            *) echo "Please answer with 'y' (Yes) or 'n' (No)." ;;
        esac
    done

    echo -e "\n-------------------------------------------------------"
    read -p "Do you want to delete processed request '$target_folder'? (Folder & ZIP) (y/n): " cleanup_confirm
    case "$cleanup_confirm" in
        [Yy]*)
            echo "Deleting request '$target_folder'..."
            rm -rf "$target_folder"
            rm -f "${target_folder}.zip"
            echo "  [✓] Folder and .zip deleted."
            ;;
        *)
            echo "  [-] Request was not deleted."
            ;;
    esac
}

# --- Hauptschleife (Menüführung) ---
while true; do
    counter=1
    unset REQUEST_NAMES HAS_DIR HAS_ZIP MENU_REQ
    declare -A REQUEST_NAMES
    declare -A HAS_DIR
    declare -A HAS_ZIP

    for dir in */; do
        [ -d "$dir" ] || continue
        req_name="${dir%/}"
        REQUEST_NAMES["$req_name"]=1
        HAS_DIR["$req_name"]=1
    done

    for zip_file in *.zip; do
        [ -e "$zip_file" ] || continue
        req_name="${zip_file%.zip}"
        REQUEST_NAMES["$req_name"]=1
        HAS_ZIP["$req_name"]=1
    done

    declare -A MENU_REQ

    echo -e "\n--- Requests ---"
    for req in $(printf "%s\n" "${!REQUEST_NAMES[@]}" | sort); do
        echo "$counter) Open $req"
        MENU_REQ[$counter]="$req"
        ((counter++))
    done

    if [ $counter -eq 1 ]; then
        echo "No requests found. Quitting script..."
        exit 0
    fi

    echo "q) Quit"
    echo ""
    read -p "Please select request (1-$((counter-1)) or q): " choice

    if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
        echo "Quit script."
        exit 0
    fi

    selected_req="${MENU_REQ[$choice]}"

    if [[ -n "$selected_req" ]]; then
        
        if [[ "${HAS_DIR[$selected_req]}" != "1" && "${HAS_ZIP[$selected_req]}" == "1" ]]; then
            echo -e "\n--> Initial opening: Extracting '$selected_req.zip'..."
            unzip -q "$selected_req.zip" -d "$selected_req"
            run_python_task "$selected_req"
            continue
        fi

        echo -e "\n=== Request: $selected_req ==="
        echo "1) Open request"
        
        if [[ "${HAS_ZIP[$selected_req]}" == "1" ]]; then
            echo "2) Reset request (Delete folder and extract zip again)"
        fi
        
        echo "3) Delete request (Folder & ZIP)"
        
        echo ""
        read -p "Select action: " sub_choice
        
        case "$sub_choice" in
            1)
                run_python_task "$selected_req"
                ;;
            2)
                if [[ "${HAS_ZIP[$selected_req]}" == "1" ]]; then
                    echo "Deleting old folder '$selected_req'..."
                    rm -rf "$selected_req"
                    
                    echo "Extracting '$selected_req.zip' again..."
                    unzip -q "$selected_req.zip" -d "$selected_req"
                    
                    echo "Request resetted successfully"
                    run_python_task "$selected_req"
                else
                    echo "Cannot reset: No ZIP file found!"
                fi
                ;;
            3)
                echo "Deleting request '$selected_req'..."
                rm -rf "$selected_req"
                rm -f "${selected_req}.zip"
                echo "  [✓] Folder and .zip deleted."
                continue
                ;;
            *)
                echo "Invalid selection!"
                ;;
        esac
    else
        echo "Invalid selection!"
    fi
done