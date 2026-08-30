# --- Klarnamen eines Icons via parse_request_xmls.py <ID> ermitteln ---
get_icon_display_name() {
    local target_folder="$1"
    local icon_id="$2"

    local display_name=""

    if [ -f "$PARSE_REQUEST_XMLS_SCRIPT" ] && [ -n "$icon_id" ]; then
        local f_single_output
        f_single_output=$(
            cd "$target_folder" || exit 1
            python3 "$PARSE_REQUEST_XMLS_SCRIPT" "$icon_id" 2>/dev/null
        )

        display_name=$(echo "$f_single_output" | grep -iE '^(Changelog|Name):' | head -n 1 | cut -d':' -f2-)
        display_name=$(trim_string "$display_name")

        if [ -z "$display_name" ]; then
            if [[ "$f_single_output" =~ name=\"([^\"]+)\" ]]; then
                display_name="${BASH_REMATCH[1]}"
            fi
        fi
    fi

    if [ -z "$display_name" ]; then
        display_name="$icon_id"
    fi

    echo "$display_name"
}
