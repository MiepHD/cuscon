# --- parse_request_xmls.py ausführen und Einträge einfügen ---
copy_xmls() {
    local target_folder="$1"
    
    if [ ! -f "$PARSE_REQUEST_XMLS_SCRIPT" ]; then
        echo -e "${RED}   [!] Error: The file 'parse_request_xmls.py' could not be found under '$PARSE_REQUEST_XMLS_SCRIPT'!${NC}"
        return 1
    fi
    
    local f_output
    f_output=$(
        cd "$target_folder" || exit 1
        python3 "$PARSE_REQUEST_XMLS_SCRIPT" -get
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
        echo -e "   ${GREEN}[✓]${NC} ${#entries[@]} Successfully inserted entries into '$(basename "$file")'."
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

        python3 "$SCRIPT_DIR/update_drawable.py" "$target_drawable" "$all_changed_ids" "$all_drawable_lines" "$WAS_VERSION_BUMPED"
    fi

    # --- Gradle finishXMLs ausführen ---
    run_gradle_finish_xmls

    # --- Git-Befehle ausgeben ---
    print_git_commands "$CURRENT_VERSION_CODE"
}
