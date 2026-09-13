#!/usr/bin/env python3
import base64
import json
import logging
import os
import struct
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
os.chdir(SCRIPT_DIR)

LOG_FILE_PATH = os.path.join(SCRIPT_DIR, "native_host.log")
FILE_PATH = os.path.abspath(os.path.join(SCRIPT_DIR, "../requests/orders_db.json"))

logging.basicConfig(
    filename=LOG_FILE_PATH,
    level=logging.DEBUG,
    format="%(asctime)s - [%(levelname)s] - %(message)s",
    encoding="utf-8",
)

def send_message(message_dict):
    try:
        encoded_message = json.dumps(message_dict).encode("utf-8")
        sys.stdout.buffer.write(struct.pack("I", len(encoded_message)))
        sys.stdout.buffer.write(encoded_message)
        sys.stdout.buffer.flush()
        status = message_dict.get("status", "unknown")
        logging.info(f"Nachricht gesendet (Status: {status})")
    except Exception as e:
        logging.error(f"Fehler beim Senden: {e}", exc_info=True)

def read_message():
    raw_length = sys.stdin.buffer.read(4)
    if not raw_length:
        return None
    message_length = struct.unpack("=I", raw_length)[0]
    encoded_message = sys.stdin.buffer.read(message_length)
    return json.loads(encoded_message)

def send_file_data():
    if os.path.exists(FILE_PATH):
        try:
            with open(FILE_PATH, "rb") as f:
                content = f.read()
                encoded_file = base64.b64encode(content).decode("utf-8")
            send_message({
                "status": "success",
                "filename": os.path.basename(FILE_PATH),
                "data": encoded_file,
            })
        except Exception as e:
            send_message({"status": "error", "message": str(e)})
    else:
        send_message({"status": "error", "message": f"Datei nicht gefunden: {FILE_PATH}"})

def save_file_data(base64_data):
    """Speichert die empfangenen JSON-Daten zurück in die Datei."""
    try:
        decoded_data = base64.b64decode(base64_data)
        # Zur Sicherheit Validiere JSON vor dem Schreiben
        json.loads(decoded_data.decode("utf-8"))
        
        with open(FILE_PATH, "wb") as f:
            f.write(decoded_data)
        
        logging.info(f"Datei erfolgreich aktualisiert: {FILE_PATH}")
        send_message({"status": "success", "action": "save", "message": "Datei gespeichert."})
    except Exception as e:
        error_msg = f"Fehler beim Speichern: {str(e)}"
        logging.error(error_msg, exc_info=True)
        send_message({"status": "error", "message": error_msg})

def handle_request(msg):
    if not msg:
        return

    action = msg.get("action")
    logging.info(f"Verarbeite Action: '{action}'")

    if action in ["connect", "get_file"]:
        send_file_data()
    elif action == "save_file":
        save_file_data(msg.get("data"))
    else:
        send_message({"status": "error", "message": f"Unbekannte Action: {action}"})

def main():
    try:
        while True:
            message = read_message()
            if message is None:
                break
            handle_request(message)
    except Exception as e:
        logging.critical(f"Hauptfehler: {e}", exc_info=True)

if __name__ == "__main__":
    main()