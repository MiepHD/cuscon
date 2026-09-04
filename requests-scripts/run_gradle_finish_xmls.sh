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
                echo -e "  ${RED}[!] ERROR: Neither ./gradlew nor 'gradle' is available.${NC}"
                return 1
            fi
        fi
    )

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}[✓]${NC} Gradle task 'finishXMLs' executed successfully."
    else
        echo -e "  ${RED}[!] ERROR: Execution of Gradle task 'finishXMLs' failed!${NC}"
    fi
}
