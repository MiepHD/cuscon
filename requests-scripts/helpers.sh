
# --- Helper-Funktion zum sauberen Trimmen von Strings ---
trim_string() {
    local var="$1"

    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

# --- Helper-Funktion: Array als kommagetrennte Zeile ausgeben ---
join_array_with_comma() {
    local -n arr=$1 # Array

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

# --- Helper zum Aktualisieren/Erweitern von .txt Changelogs ---
update_single_txt_changelog() {
    local file_path="$1"
    local prefix="$2"
    local -n items_arr=$3 # Array

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
            python3 "$COMPARE_REQUEST_TO_EXISTING_ICONS_SCRIPT"
        )
        
        if ! echo "$check_output" | grep -q "$new_hex"; then
            is_unique=true
        fi
    done

    echo "$new_hex"
}
