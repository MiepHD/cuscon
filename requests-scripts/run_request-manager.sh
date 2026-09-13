run_request-manager() {
    local VENV_DIR="${SCRIPT_DIR}/.venv"
    local PYTHON_SCRIPT="${SCRIPT_DIR}/requests-manager.py"

    # 1. Sicherstellen, dass Python installiert ist
    ensure_python

    # 2. Virtual Environment anlegen, falls noch nicht vorhanden
    if [ ! -d "$VENV_DIR" ]; then
        echo "[INFO] Erstelle Python Virtual Environment..."
        python3 -m venv "$VENV_DIR"
    fi

    # 3. Pip und Abhängigkeiten im venv installieren/aktualisieren
    echo "[INFO] Überprüfe und installiere Abhängigkeiten..."
    "$VENV_DIR/bin/pip" install --upgrade pip --quiet
    "$VENV_DIR/bin/pip" install msal google-api-python-client requests --quiet

    # 4. Prüfen, ob das Python-Skript existiert
    if [ ! -f "$PYTHON_SCRIPT" ]; then
        echo "[FEHLER] Skript '$PYTHON_SCRIPT' wurde nicht gefunden!"
        return 1
    fi

    # 5. Skript ausführen
    echo "[INFO] Starte Processing-Skript..."
    "$VENV_DIR/bin/python" "$PYTHON_SCRIPT"
}
