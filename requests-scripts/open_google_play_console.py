import json
import os
import subprocess
import sys
import time
import webbrowser

URL = "https://play.google.com/console/u/0/developers/9102135194134726659/orders"
DB_FILE = "orders_db.json"
CHECK_INTERVAL = 2  # Prüfintervall in Sekunden
TIMEOUT = 300  # Maximale Wartezeit in Sekunden (5 Minuten)

# 1. Browser öffnen und Prozess merken
browser_process = None

try:
    # Versuche Chromium direkt als Subprozess zu starten
    browser_process = subprocess.Popen(["chromium", URL])
    print("[+] Chromium erfolgreich gestartet.")
except (FileNotFoundError, OSError):
    print("Chromium konnte nicht direkt gestartet werden. Fallback auf Standardbrowser:")
    webbrowser.open(URL)

# Zeitstempel der Datei vor der Verarbeitung sichern
last_mtime = os.path.getmtime(DB_FILE) if os.path.exists(DB_FILE) else 0

print(f"\n[+] Warten auf Aktualisierung von '{DB_FILE}' durch die Extension...")

start_time = time.time()
updated = False

# 2. Auf Dateiänderung warten
while time.time() - start_time < TIMEOUT:
    if os.path.exists(DB_FILE):
        current_mtime = os.path.getmtime(DB_FILE)
        if current_mtime > last_mtime:
            updated = True
            print("[+] Dateiänderung erkannt! Starte Auswertung...\n")
            break
    time.sleep(CHECK_INTERVAL)

# 3. Browser-Prozess beenden
if browser_process:
    print("[+] Schließe Chromium...")
    browser_process.terminate()  # Sendet SIGTERM zum Schließen
    try:
        browser_process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        browser_process.kill()  # Erzwingt das Beenden, falls er hängengeblieben ist
else:
    # Fallback für Linux/macOS/Windows, falls webbrowser verwendet werden musste
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

# 4. JSON-Daten laden und auswerten
try:
    with open(DB_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception as e:
    print(f"[!] Fehler beim Lesen der '{DB_FILE}': {e}")
    exit(1)

orders = data.get("orders", {})
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

# 5. Ergebnisse ausgeben
print("=" * 60)
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