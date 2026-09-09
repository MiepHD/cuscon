# --- Task finishXMLs ausführen ---
run_gradle_finish_xmls() {
    echo -e "\n--> Running 'finishXMLs.sh' script..."
    
    local root_dir
    root_dir="$(cd "$SCRIPT_DIR/.." && pwd)"

    (
        cd "$root_dir" || exit 1
        
        if [ -f "./app/finishXMLs.sh" ]; then
            chmod +x ./app/finishXMLs.sh 2>/dev/null
            cd app
            bash ./finishXMLs.sh
            cd ..
        else
            echo -e "  ${RED}[!] ERROR: 'finishXMLs.sh' was not found in $root_dir/app.${NC}"
            return 1
        fi
    )

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}[✓]${NC} Script 'finishXMLs.sh' executed successfully."
    else
        echo -e "  ${RED}[!] ERROR: Execution of 'finishXMLs.sh' failed!${NC}"
    fi
}