# --- Task Steuerung ---
process_request() {
    local target_folder="$1"
    
    if [ ! -f "$COMPARE_REQUEST_TO_EXISTING_ICONS_SCRIPT" ]; then
        echo "Error: 'compare_request_to_existing_icons.py' could not be found under '$COMPARE_REQUEST_TO_EXISTING_ICONS_SCRIPT'!"
        return 1
    fi

    ensure_python
    sanitize_png_names "$target_folder"

    echo -e "\n--> Opening '$target_folder' ..."
    
    local py_output
    py_output=$(
        cd "$target_folder" || exit 1
        python3 "$COMPARE_REQUEST_TO_EXISTING_ICONS_SCRIPT"
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
                copy_xmls "$target_folder"
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
