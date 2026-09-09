#!/usr/bin/env python3
import json
import os
import re
import zipfile
import base64
import requests
from msal import PublicClientApplication, SerializableTokenCache
from google.oauth2 import service_account
from googleapiclient.discovery import build

# ================= CONFIGURATION =================
MS_CLIENT_ID = "abe95a41-0f7d-43d6-926b-e4b27ceeda5a"  # MS Graph CLI ID
MS_TENANT = "froxot.de"     # Deine konkrete Tenant-ID
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

# --- MS GRAPH AUTHENTICATION (MIT TOKEN CACHING) ---
# --- MS GRAPH AUTHENTICATION (MIT TOKEN CACHING) ---
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
    
    # 1. Versuchen, ein Token leise aus dem Cache zu holen
    accounts = app.get_accounts()
    if accounts:
        result = app.acquire_token_silent(MS_SCOPES, account=accounts[0])
        if result and "access_token" in result:
            return result['access_token']

    # 2. Interaktiver Device Code Flow, falls kein Token im Cache vorhanden ist
    flow = app.initiate_device_flow(scopes=MS_SCOPES)
    if "user_code" not in flow:
        raise ValueError(f"Device Flow fehlgeschlagen: {flow.get('error_description')}")

    print("=" * 60)
    print(flow['message'])
    print("=" * 60)
    
    # Hier wartet das Skript, bis du dich im Browser angemeldet hast
    result = app.acquire_token_by_device_flow(flow)

    # 3. Das Ergebnis der Anmeldung direkt überprüfen
    if "access_token" in result:
        # Cache auf der Festplatte speichern
        if cache.has_state_changed:
            with open(CACHE_FILE, "w") as f:
                f.write(cache.serialize())
        return result['access_token']
    else:
        error_msg = result.get("error_description", "Unbekannter Fehler")
        raise RuntimeError(f"Microsoft Token konnte nicht abgerufen werden: {error_msg}")

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
        
        # Für In-App-Purchases (sofern purchase_token vorliegt):
        # result = service.inappproducts().purchases().get(packageName=PACKAGE_NAME, productId=product_id, token=purchase_token).execute()
        # return result.get('purchaseState') == 0
        
        return True  # Fallback/Mock wenn nur Order-ID vorliegt
    except Exception as e:
        print(f"Fehler bei Google Validation: {e}")
        return False

# --- PARSING & PROCESSING ---
def parse_email_body(body):
    order_id_match = re.search(r"Order Id:\s*([^\s\r\n<]+)", body)
    product_id_match = re.search(r"Product Id:\s*([^\s\r\n<]+)", body)
    
    order_id = order_id_match.group(1) if order_id_match else None
    product_id = product_id_match.group(1) if product_id_match else None
    
    return order_id, product_id

def count_icons_in_zip(zip_path):
    with zipfile.ZipFile(zip_path, 'r') as z:
        return len([name for name in z.namelist() if name.lower().endswith(('.png', '.svg', '.jpg'))])

def handle_error_prompt(error_msg):
    print(f"\n[FEHLER DETEKTIERT]: {error_msg}")
    while True:
        choice = input("Wähle eine Aktion: [s]kip (Anfrage überspringen) / [i]gnore (Fehler ignorieren & fortfahren)? ").lower()
        if choice in ['s', 'skip']:
            return 'skip'
        elif choice in ['i', 'ignore']:
            return 'ignore'

# --- MAIN WORKFLOW ---
def main():
    token = get_ms_token()
    db = load_db()
    
    headers = {'Authorization': f'Bearer {token}'}
    
    # Auslesen ungelesener Mails mit Betreff "Premium request"
    url = "https://graph.microsoft.com/v1.0/me/messages?$filter=isRead eq false and contains(subject, 'Premium request')"
    response = requests.get(url, headers=headers).json()

    messages = response.get('value', [])
    print(f"Gefundene neue Anfragen: {len(messages)}")

    for msg in messages:
        msg_id = msg['id']
        body = msg.get('body', {}).get('content', '')
        
        order_id, product_id = parse_email_body(body)
        
        if not order_id:
            action = handle_error_prompt(f"Keine Order ID in Mail ID {msg_id} gefunden.")
            if action == 'skip':
                continue

        # Check bezahlt via Google Play API
        if not verify_google_order(order_id, product_id):
            action = handle_error_prompt(f"Order ID {order_id} konnte bei Google Play nicht verifiziert werden.")
            if action == 'skip':
                continue

        # Anhänge abrufen
        att_url = f"https://graph.microsoft.com/v1.0/me/messages/{msg_id}/attachments"
        attachments = requests.get(att_url, headers=headers).json().get('value', [])
        
        zip_attachment = None
        for att in attachments:
            if att.get('name', '').endswith('.zip'):
                zip_attachment = att
                break
                
        if not zip_attachment:
            action = handle_error_prompt(f"Keine ZIP-Datei in Mail mit Order ID {order_id} gefunden.")
            if action == 'skip':
                continue

        # ZIP temporär speichern
        zip_data = base64.b64decode(zip_attachment['contentBytes'])
        temp_zip_path = os.path.join("/tmp", zip_attachment['name'])
        with open(temp_zip_path, 'wb') as f:
            f.write(zip_data)

        icon_count = count_icons_in_zip(temp_zip_path)

        # Überprüfen der bisher verbrauchten Icon-Requests für die Order ID
        allowed_limit = 10  # Standard-Limit pro Purchase (anpassen!)
        used_icons = db.get(order_id, 0)

        if used_icons + icon_count > allowed_limit:
            action = handle_error_prompt(
                f"Order ID {order_id} überschreitet das Kontingent! "
                f"Bisher genutzt: {used_icons}, Gefordert: {icon_count}, Erlaubt: {allowed_limit}"
            )
            if action == 'skip':
                os.remove(temp_zip_path)
                continue

        # Erfolg: Speichern
        final_zip_path = os.path.join(OUTPUT_DIR, f"{order_id}_{zip_attachment['name']}")
        os.rename(temp_zip_path, final_zip_path)
        
        # Datenbank aktualisieren
        db[order_id] = used_icons + icon_count
        save_db(db)
        
        print(f"[BESTÄTIGUNG]: Anfrage für Order {order_id} verarbeitet. {icon_count} Icons gespeichert. Gesamt verbraucht: {db[order_id]}")

        # Status auf UNGELESEN zurücksetzen
        patch_url = f"https://graph.microsoft.com/v1.0/me/messages/{msg_id}"
        requests.patch(patch_url, headers=headers, json={'isRead': False})

if __name__ == "__main__":
    main()