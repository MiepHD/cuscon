import glob
import json
import os
import subprocess
import sys
import time
import webbrowser
import zipfile

URL = "https://play.google.com/console/u/0/developers/9102135194134726659/orders"
DB_FILE = "orders_db.json"
CHECK_INTERVAL = 2  # Prüfintervall in Sekunden
TIMEOUT = 300  # Maximale Wartezeit in Sekunden (5 Minuten)

# 0. JSON-Daten laden und prüfen, ob überhaupt etwas zu tun ist
if not os.path.exists(DB_FILE):
    print(f"[!] Datei '{DB_FILE}' wurde nicht gefunden.")
    exit(1)

try:
    with open(DB_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception as e:
    print(f"[!] Fehler beim Lesen von '{DB_FILE}': {e}")
    exit(1)

orders = data.get("orders", {})

# Prüfen, ob bei mindestens einer Order 'paid' oder 'totalavailable' auf None/null steht
needs_browser_update = False
for info in orders.values():
    if isinstance(info, dict):
        if info.get("paid") is None or info.get("totalavailable") is None:
            needs_browser_update = True
            break

# 1. & 2. Browser öffnen und auf Dateiänderung warten (nur wenn nötig)
if needs_browser_update:
    print("[+] Unvollständige Einträge gefunden. Starte Browser zur Aktualisierung...")

    browser_process = None

    try:
        # Versuche Chromium direkt als Subprozess zu starten
        browser_process = subprocess.Popen(["chromium", URL])
        print("[+] Chromium erfolgreich gestartet.")
    except (FileNotFoundError, OSError):
        print("Chromium konnte nicht direkt gestartet werden. Fallback auf Standardbrowser:")
        webbrowser.open(URL)

    # Zeitstempel der Datei vor der Verarbeitung sichern
    last_mtime = os.path.getmtime(DB_FILE)

    print(f"\n[+] Warten auf Aktualisierung von '{DB_FILE}' durch die Extension...")

    start_time = time.time()
    updated = False

    while time.time() - start_time < TIMEOUT:
        if os.path.exists(DB_FILE):
            current_mtime = os.path.getmtime(DB_FILE)
            if current_mtime > last_mtime:
                updated = True
                print("[+] Dateiänderung erkannt! Starte Auswertung...\n")
                break
        time.sleep(CHECK_INTERVAL)

    # Browser-Prozess beenden
    if browser_process:
        print("[+] Schließe Chromium...")
        browser_process.terminate()
        try:
            browser_process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            browser_process.kill()
    else:
        print("[+] Versuche Browser-Prozesse per Systembefehl zu beenden...")
        if sys.platform.startswith("linux"):
            os.system("pkill -f chromium")
        elif sys.platform == "win32":
            os.system("taskkill /IM chromium.exe /F")

    if not updated:
        print(
            f"[!] Timeout ({TIMEOUT}s) erreicht: Keine Aktualisierung der '{DB_FILE}' festgestellt."
        )
        exit(1)

    # Aktualisierte Daten nach Browser-Durchlauf neu einlesen
    try:
        with open(DB_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            orders = data.get("orders", {})
    except Exception as e:
        print(f"[!] Fehler beim erneuten Lesen der '{DB_FILE}': {e}")
        exit(1)

else:
    print("[+] Keine unvollständigen Daten vorhanden ('paid' und 'totalavailable' vollständig). Überspringe Browser-Start.\n")

# 3. Dateizuordnung und interaktive Anpassungen
db_modified = False  # Trackt, ob Werte angepasst wurden

for order_id, info in orders.items():
    if not isinstance(info, dict):
        continue

    # --- Suche nach allen ZIP-Dateien zur OrderID ---
    matching_zips = set(
        glob.glob(f"{order_id}.zip") + glob.glob(f"{order_id}_*.zip")
    )
    
    contained_files = []

    if matching_zips:
        for zip_path in sorted(matching_zips):
            try:
                with zipfile.ZipFile(zip_path, "r") as zf:
                    for file_info in zf.infolist():
                        if file_info.is_dir():
                            continue
                        if not file_info.filename.lower().endswith(".xml"):
                            contained_files.append(file_info.filename)
            except zipfile.BadZipFile:
                print(f"[!] Warnung: '{zip_path}' ist eine beschädigte ZIP-Datei.")
            except Exception as e:
                print(f"[!] Fehler beim Lesen von '{zip_path}': {e}")
    else:
        print(f"[!] Keine passenden ZIP-Dateien für Order '{order_id}' gefunden.")

    info["files"] = contained_files
    db_modified = True

    # Temporäre Werte für Interaktionsabfrage prüfen
    requested = info.get("requested", 0)
    totalavailable = info.get("totalavailable", 0)

    if (
        totalavailable is not None
        and requested is not None
        and requested > totalavailable
    ):
        print("\n" + "=" * 60)
        print(f"⚠️ LIMIT ÜBERSCHRITTEN BEI ORDER: {order_id}")
        print(f"   Angefordert: {requested} | Erlaubt: {totalavailable}")
        if matching_zips:
            print(f"   Gefundene Archive: {', '.join(sorted(matching_zips))}")
        print("=" * 60)

        # Abfrage: Dateiliste anzeigen
        show_files = input("Möchtest du die Liste der angefragten Dateien sehen? (j/n): ").strip().lower()
        if show_files == 'j':
            print(f"\nEnthaltene Dateien für Order '{order_id}' (ohne XML):")
            if contained_files:
                for idx, fname in enumerate(contained_files, 1):
                    print(f"  {idx}. {fname}")
            else:
                print("  (Keine übereinstimmenden Dateien gefunden)")
            print()

        # Abfrage: Wert 'requested' manuell anpassen
        change_req = input("Möchtest du 'requested' für diese Order manuell anpassen? (j/n): ").strip().lower()
        if change_req == 'j':
            while True:
                new_val = input(f"Neuer Wert für 'requested' (aktuell {requested}): ").strip()
                if new_val.isdigit():
                    info["requested"] = int(new_val)
                    print(f"[+] 'requested' für Order '{order_id}' wurde auf {info['requested']} gesetzt.")
                    break
                else:
                    print("[!] Bitte eine gültige Ganzzahl eingeben.")

# 4. Abschließende Auswertung der Daten
issues = []

for order_id, info in orders.items():
    if not isinstance(info, dict):
        continue

    paid = info.get("paid")
    requested = info.get("requested", 0)
    totalavailable = info.get("totalavailable", 0)

    # Regel 1: Unbezahlt
    if paid is False:
        issues.append(
            f"❌ Order '{order_id}': Bestellung ist nicht bezahlt (paid: false)."
        )

    # Regel 2: Kontingent überschritten
    if (
        totalavailable is not None
        and requested is not None
        and requested > totalavailable
    ):
        issues.append(
            f"⚠️ Order '{order_id}': Limit überschritten! Angefordert: {requested} | Erlaubt: {totalavailable}"
        )

# Aktualisierte Daten zurück in die JSON-Datei schreiben
if db_modified:
    try:
        with open(DB_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
        print(f"\n[+] '{DB_FILE}' wurde erfolgreich aktualisiert.")
    except Exception as e:
        print(f"[!] Fehler beim Schreiben der '{DB_FILE}': {e}")

# 5. Ergebnisse ausgeben
print("\n" + "=" * 60)
print("ERGEBNIS DER BESTELLPRÜFUNG")
print("=" * 60)

if issues:
    print(
        f"Es wurden {len(issues)} auffällige Bestellung(en) identifiziert:\n"
    )
    for issue in issues:
        print(f" - {issue}")
else:
    print(
        "✅ Alle verarbeiteten Bestellungen sind bezahlt und liegen im zulässigen Kontingent."
    )

print("=" * 60)