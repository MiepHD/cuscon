
# --- Gradle, ThemeInfo & ThemeCfg verwalten ---
manage_gradle_version_and_changelog() {
    local target_folder="$1"

    local gradle_file="../app/build.gradle"
    local themeinfo_file="../app/src/main/res/xml/themeinfo.xml"
    local themecfg_file="../app/src/main/res/xml/themecfg.xml"

    WAS_VERSION_BUMPED=false

    if [ ! -f "$gradle_file" ]; then
        echo -e "${RED}[!] Error: Gradle file '$gradle_file' not found.${NC}"
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
        echo "--> Release v$version_name already exists on GitHub. Increasing version..."
        
        WAS_VERSION_BUMPED=true

        local new_version_code=$((version_code + 1))
        local new_version_name
        new_version_name=$(python3 "$SCRIPT_DIR/increment_version.py" "$version_name")

        echo -e "  ${GREEN}[✓]${NC} New Version Code : $new_version_code"
        echo -e "  ${GREEN}[✓]${NC} New Version Name : $new_version_name"

        sed -i -E "s/(versionCode\s+)[0-9]+/\1$new_version_code/" "$gradle_file"
        sed -i -E "s/(versionName\s+['\"])[^'\"]+(['\"])/\1$new_version_name\2/" "$gradle_file"
        echo -e "  ${GREEN}[✓]${NC} build.gradle updated."

        if [ -f "$themeinfo_file" ]; then
            sed -i -E "s/(<versionCode>)[0-9]+(<\/versionCode>)/\1$new_version_code\2/" "$themeinfo_file"
            sed -i -E "s/(<versionName>)[^<]+(<\/versionName>)/\1$new_version_name\2/" "$themeinfo_file"
            echo -e "  ${GREEN}[✓]${NC} themeinfo.xml updated."
        fi

        if [ -f "$themecfg_file" ]; then
            sed -i -E "s/(<version>)[0-9]+(<\/version>)/\1$new_version_code\2/" "$themecfg_file"
            echo -e "  ${GREEN}[✓]${NC} themecfg.xml updated."
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
