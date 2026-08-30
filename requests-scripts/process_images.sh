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

        python3 "$SCRIPT_DIR/resize_and_convert_webp.py" "$img" "$target_webp"
        ((process_counter++))
    done
    echo -e "\n[✓] Image processing completed."
}
