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
