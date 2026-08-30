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

        python3 "$SCRIPT_DIR/write_metadata_changelogs.py" "$xml_changelog_file" "$version_name" "$today_date" \
                 "$(join_array_with_comma EN_ADDED)" \
                 "$(join_array_with_comma EN_UPDATED)" \
                 "$(join_array_with_comma EN_FIXED)" \
                 "$(join_array_with_comma EN_IMPROVED)"
    else
        echo "  [!] Warning: '$xml_changelog_file' not found!"
    fi
}
