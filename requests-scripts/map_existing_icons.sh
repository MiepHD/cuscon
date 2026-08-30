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
