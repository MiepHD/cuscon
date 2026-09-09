#!/usr/bin/env python3
import json
import os
import re
import zipfile
import base64
import shutil
import requests
from msal import PublicClientApplication, SerializableTokenCache
from google.oauth2 import service_account
from googleapiclient.discovery import build

# ================= CONFIGURATION =================
MS_CLIENT_ID = "abe95a41-0f7d-43d6-926b-e4b27ceeda5a"  # MS Graph CLI ID / Azure App Client ID
MS_TENANT = "froxot.de"     # Deine konkrete Tenant-ID oder Domain
MS_SCOPES = ["https://graph.microsoft.com/Mail.ReadWrite"]

GOOGLE_JSON_PATH = "google_credentials.json"
PACKAGE_NAME = "com.froxot.cuscon"

CACHE_FILE = "tokens_cache.json"
DATABASE_FILE = "orders_db.json"
OUTPUT_DIR = "."
# =================================================

os.makedirs(OUTPUT_DIR, exist_ok=True)

def load_db():
    if os.path.exists(DATABASE_FILE):
        with open(DATABASE_FILE, "r") as f:
            return json.load(f)
    return {}

def save_db(db):
    with open(DATABASE_FILE, "w") as f:
        json.dump(db, f, indent=4)

# --- MS GRAPH AUTHENTICATION ---
def get_ms_token():
    cache = SerializableTokenCache()
    if os.path.exists(CACHE_FILE):
        with open(CACHE_FILE, "r") as f:
            cache.deserialize(f.read())

    app = PublicClientApplication(
        MS_CLIENT_ID, 
        authority=f"https://login.microsoftonline.com/{MS_TENANT}",
        token_cache=cache
    )
    
    accounts = app.get_accounts()
    if accounts:
        result = app.acquire_token_silent(MS_SCOPES, account=accounts[0])
        if result and "access_token" in result:
            return result['access_token']

    flow = app.initiate_device_flow(scopes=MS_SCOPES)
    if "user_code" not in flow:
        raise ValueError(f"Device Flow fehlgeschlagen: {flow.get('error_description')}")

    print("=" * 60)
    print(flow['message'])
    print("=" * 60)
    
    result = app.acquire_token_by_device_flow(flow)

    if "access_token" in result:
        if cache.has_state_changed:
            with open(CACHE_FILE, "w") as f:
                f.write(cache.serialize())
        return result['access_token']
    else:
        error_msg = result.get("error_description", "Unbekannter Fehler")
        raise RuntimeError(f"Microsoft Token konnte nicht abgerufen werden: {error_msg}")

# --- HELPER: HTML TO CLEAN TEXT ---
def clean_html(html_content):
    """Entfernt HTML-Tags und bereinigt Mehrfach-Leerzeichen/Zeilenumbrüche."""
    text = re.sub(r'<[^>]+>', ' ', html_content)
    text = re.sub(r'&nbsp;', ' ', text)
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    return "\n".join(lines)

# --- GOOGLE PLAY VALIDATION ---
def verify_google_order(order_id, product_id, purchase_token=None):
    if not os.path.exists(GOOGLE_JSON_PATH):
        print(f"[!] Google Credentials File '{GOOGLE_JSON_PATH}' fehlt.")
        return False

    try:
        credentials = service_account.Credentials.from_service_account_file(
            GOOGLE_JSON_PATH, scopes=['https://www.googleapis.com/auth/androidpublisher']
        )
        service = build('androidpublisher', 'v3', credentials=credentials)
        return True  # Fallback/Mock bis zur vollständigen API-Verknüpfung
    except Exception as e:
        print(f"Fehler bei Google Validation: {e}")
        return False

# --- PARSING & INTERACTIVE PROMPT ---
def parse_email_body(body_text):
    order_id_match = re.search(r"Order\s*Id\s*:\s*([^\s\r\n<]+)", body_text, re.IGNORECASE)
    product_id_match = re.search(r"Product\s*Id\s*:\s*([^\s\r\n<]+)", body_text, re.IGNORECASE)
    
    order_id = order_id_match.group(1) if order_id_match else None
    product_id = product_id_match.group(1) if product_id_match else None
    
    return order_id, product_id

def count_icons_in_zip(zip_path):
    with zipfile.ZipFile(zip_path, 'r') as z:
        return len([name for name in z.namelist() if name.lower().endswith(('.png', '.svg', '.jpg'))])

def handle_interactive_decision(subject, preview_body, error_msg):
    print("\n" + "=" * 60)
    print(f"[PRÜFUNG FEHLGESCHLAGEN]: {error_msg}")
    print(f"BETREFF: {subject}")
    print("-" * 60)
    print("INHALT (Auszug):")
    print(preview_body[:400] + ("..." if len(preview_body) > 400 else ""))
    print("=" * 60)

    while True:
        choice = input("Wähle eine Aktion: [s]kip (Überspringen) / [m]anual (Order-ID händisch eingeben) / [i]gnore (Ignorieren & als gelesen abheften)? ").lower()
        if choice in ['s', 'skip']:
            return 'skip', None
        elif choice in ['m', 'manual']:
            manual_id = input("Bitte gib die Order-ID manuell ein: ").strip()
            return 'manual', manual_id
        elif choice in ['i', 'ignore']:
            return 'ignore', None

def mark_as_read(msg_id, headers, status=True):
    patch_url = f"https://graph.microsoft.com/v1.0/me/messages/{msg_id}"
    requests.patch(patch_url, headers=headers, json={'isRead': status})

# --- MAIN WORKFLOW ---
def main():
    token = get_ms_token()
    db = load_db()
    
    headers = {'Authorization': f'Bearer {token}'}
    
    url = "https://graph.microsoft.com/v1.0/me/messages?$filter=isRead eq false and contains(subject, 'Premium request')"
    response = requests.get(url, headers=headers).json()

    messages = response.get('value', [])
    print(f"Gefundene neue Anfragen: {len(messages)}")

    for msg in messages:
        msg_id = msg['id']
        subject = msg.get('subject', 'Kein Betreff')
        raw_body = msg.get('body', {}).get('content', '')
        
        clean_text = clean_html(raw_body)
        order_id, product_id = parse_email_body(clean_text)
        
        # 1. Order ID Prüfung
        if not order_id:
            action, manual_id = handle_interactive_decision(
                subject, clean_text, "Keine Order ID automatisch erkannt."
            )
            if action == 'skip':
                continue
            elif action == 'ignore':
                mark_as_read(msg_id, headers, status=True)
                print(f"[!] Mail '{subject}' wurde ignoriert und als gelesen markiert.")
                continue
            elif action == 'manual':
                order_id = manual_id

        # 2. Google Play API Prüfung
        if not verify_google_order(order_id, product_id):
            action, _ = handle_interactive_decision(
                subject, clean_text, f"Order ID {order_id} konnte bei Google Play nicht verifiziert werden."
            )
            if action == 'skip':
                continue
            elif action == 'ignore':
                mark_as_read(msg_id, headers, status=True)
                print(f"[!] Order ID '{order_id}' wurde ignoriert und als gelesen markiert.")
                continue

        # 3. Anhänge abrufen
        att_url = f"https://graph.microsoft.com/v1.0/me/messages/{msg_id}/attachments"
        attachments = requests.get(att_url, headers=headers).json().get('value', [])
        
        zip_attachment = None
        for att in attachments:
            if att.get('name', '').endswith('.zip'):
                zip_attachment = att
                break
                
        if not zip_attachment:
            action, _ = handle_interactive_decision(
                subject, clean_text, f"Keine ZIP-Datei in Mail mit Order ID {order_id} gefunden."
            )
            if action == 'skip':
                continue
            elif action == 'ignore':
                mark_as_read(msg_id, headers, status=True)
                print(f"[!] Mail ohne ZIP (Order ID: {order_id}) ignoriert und als gelesen markiert.")
                continue

        if not zip_attachment or 'id' not in zip_attachment:
            print("[!] Warnung: Keine gültige ZIP-Datei vorhanden. Überspringe E-Mail.")
            continue

        # 4. ZIP-Inhalt über $value-Endpunkt herunterladen
        att_id = zip_attachment['id']
        download_url = f"https://graph.microsoft.com/v1.0/me/messages/{msg_id}/attachments/{att_id}/$value"
        res_download = requests.get(download_url, headers=headers)

        if res_download.status_code != 200:
            action, _ = handle_interactive_decision(
                subject, clean_text, f"Fehler beim Download des ZIP-Anhangs (Status-Code: {res_download.status_code})."
            )
            if action == 'skip':
                continue
            elif action == 'ignore':
                mark_as_read(msg_id, headers, status=True)
                continue

        # 5. Speichern und Zählen
        temp_zip_path = os.path.join("/tmp", zip_attachment['name'])
        with open(temp_zip_path, 'wb') as f:
            f.write(res_download.content)

        icon_count = count_icons_in_zip(temp_zip_path)

        # 6. Kontingent-Prüfung
        allowed_limit = 10
        used_icons = db.get(order_id, 0)

        if used_icons + icon_count > allowed_limit:
            action, _ = handle_interactive_decision(
                subject, clean_text, 
                f"Order ID {order_id} überschreitet Kontingent! "
                f"Bisher: {used_icons}, Gefordert: {icon_count}, Erlaubt: {allowed_limit}"
            )
            if action == 'skip':
                os.remove(temp_zip_path)
                continue
            elif action == 'ignore':
                os.remove(temp_zip_path)
                mark_as_read(msg_id, headers, status=True)
                continue

        # 7. Datei verschieben & DB aktualisieren
        final_zip_path = os.path.join(OUTPUT_DIR, f"{order_id}_{zip_attachment['name']}")
        shutil.move(temp_zip_path, final_zip_path)
        
        db[order_id] = used_icons + icon_count
        save_db(db)
        
        print(f"\n[BESTÄTIGUNG]: Anfrage für Order '{order_id}' erfolgreich verarbeitet.")
        print(f"Icons gespeichert: {icon_count} | Gesamt verbraucht: {db[order_id]}/{allowed_limit}")

        # Für erfolgreich verarbeitete Mails auf ungelesen belassen (wie von dir definiert)
        mark_as_read(msg_id, headers, status=False)

if __name__ == "__main__":
    main()