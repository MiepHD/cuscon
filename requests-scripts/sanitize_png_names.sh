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
            echo -e "  ${GREEN}[✓]${NC} Automatic renaming: '$filename' -> '$new_hex_name.png'"
            
            local xml_files=("$target_folder/appfilter.xml" "$target_folder/theme_resources.xml")
            for xml in "${xml_files[@]}"; do
                if [ -f "$xml" ]; then
                    sed -i "s/=\"${name}\"/=\"${new_hex_name}\"/g" "$xml"
                    echo -e "  ${GREEN}[✓]${NC} XML updated: $(basename "$xml")"
                fi
            done
        fi
    done
}
