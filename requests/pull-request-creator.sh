#!/bin/bash

# Absolute Pfade ermitteln
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../requests-scripts" && pwd)"
COMPARE_REQUEST_TO_EXISTING_ICONS_SCRIPT="$SCRIPT_DIR/compare_request_to_existing_icons.py"
PARSE_REQUEST_XMLS_SCRIPT="$SCRIPT_DIR/parse_request_xmls.py"

# Alle Skripte im Ordner laden
if [ -d "$SCRIPT_DIR" ]; then
    for module in "$SCRIPT_DIR"/*.sh; do
        [ -r "$module" ] && source "$module"
    done
fi

TARGET_DIR="${1:-.}"
cd "$TARGET_DIR" || exit 1

# Globale Variablen
WAS_VERSION_BUMPED=false
CURRENT_VERSION_CODE=""

# Globale Arrays für Changelog-Kategorisierung
declare -a DE_ADDED EN_ADDED
declare -a DE_UPDATED EN_UPDATED
declare -a DE_FIXED EN_FIXED
declare -a DE_IMPROVED EN_IMPROVED

# --- Menüführung ---
while true; do
    counter=1
    unset REQUEST_NAMES HAS_DIR HAS_ZIP MENU_REQ
    declare -A REQUEST_NAMES
    declare -A HAS_DIR
    declare -A HAS_ZIP

    for dir in */; do
        [ -d "$dir" ] || continue
        req_name="${dir%/}"
        REQUEST_NAMES["$req_name"]=1
        HAS_DIR["$req_name"]=1
    done

    for zip_file in *.zip; do
        [ -e "$zip_file" ] || continue
        req_name="${zip_file%.zip}"
        REQUEST_NAMES["$req_name"]=1
        HAS_ZIP["$req_name"]=1
    done

    declare -A MENU_REQ

    echo -e "\n--- Requests ---"
    for req in $(printf "%s\n" "${!REQUEST_NAMES[@]}" | sort); do
        echo "$counter) Open $req"
        MENU_REQ[$counter]="$req"
        ((counter++))
    done

    if [ $counter -eq 1 ]; then
        echo "No requests found. Quitting script..."
        exit 0
    fi

    echo "q) Quit"
    echo ""
    read -p "Please select request (1-$((counter-1)) or q): " choice

    if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
        echo "Quit script."
        exit 0
    fi

    selected_req="${MENU_REQ[$choice]}"

    if [[ -n "$selected_req" ]]; then
        
        if [[ "${HAS_DIR[$selected_req]}" != "1" && "${HAS_ZIP[$selected_req]}" == "1" ]]; then
            echo -e "\n--> Initial opening: Extracting '$selected_req.zip'..."
            unzip -q "$selected_req.zip" -d "$selected_req"
            process_request "$selected_req"
            continue
        fi

        echo -e "\n=== Request: $selected_req ==="
        echo "1) Open request"
        
        if [[ "${HAS_ZIP[$selected_req]}" == "1" ]]; then
            echo "2) Reset request (Delete folder and extract zip again)"
        fi
        
        echo "3) Delete request (Folder & ZIP)"
        
        echo ""
        read -p "Select action: " sub_choice
        
        case "$sub_choice" in
            1)
                process_request "$selected_req"
                ;;
            2)
                if [[ "${HAS_ZIP[$selected_req]}" == "1" ]]; then
                    echo "Deleting old folder '$selected_req'..."
                    rm -rf "$selected_req"
                    
                    echo "Extracting '$selected_req.zip' again..."
                    unzip -q "$selected_req.zip" -d "$selected_req"
                    
                    echo "Request resetted successfully"
                    process_request "$selected_req"
                else
                    echo "Cannot reset: No ZIP file found!"
                fi
                ;;
            3)
                echo "Deleting request '$selected_req'..."
                rm -rf "$selected_req"
                rm -f "${selected_req}.zip"
                echo "  [✓] Folder and .zip deleted."
                continue
                ;;
            *)
                echo "Invalid selection!"
                ;;
        esac
    else
        echo "Invalid selection!"
    fi
done