#!/usr/bin/env python3
import base64
import json
import logging
import os
import struct
import sys

# 1. Pfade definieren
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
os.chdir(SCRIPT_DIR)

LOG_FILE_PATH = os.path.join(SCRIPT_DIR, "native_host.log")
FILE_PATH = os.path.abspath(os.path.join(SCRIPT_DIR, "../requests/orders_db.json"))

# 2. Logging konfigurieren
logging.basicConfig(
    filename=LOG_FILE_PATH,
    level=logging.DEBUG,
    format="%(asctime)s - [%(levelname)s] - %(message)s",
    encoding="utf-8",
)

logging.info("=== Native Messaging Host gestartet ===")
logging.info(f"Arbeitsverzeichnis: {SCRIPT_DIR}")
logging.info(f"Ziel-Datei-Pfad: {FILE_PATH}")


def send_message(message_dict):
    """Sendet eine JSON-Nachricht an die Extension und protokolliert die Antwort."""
    try:
        encoded_message = json.dumps(message_dict).encode("utf-8")
        sys.stdout.buffer.write(struct.pack("I", len(encoded_message)))
        sys.stdout.buffer.write(encoded_message)
        sys.stdout.buffer.flush()

        status = message_dict.get("status", "unknown")
        logging.info(
            f"Nachricht an Extension gesendet (Status: {status}, Länge: {len(encoded_message)} Bytes)"
        )
    except Exception as e:
        logging.error(
            f"Fehler beim Senden der Nachricht an die Extension: {e}",
            exc_info=True,
        )


def read_message():
    """Liest eine JSON-Nachricht von stdin und protokolliert den Empfang."""
    raw_length = sys.stdin.buffer.read(4)
    if not raw_length:
        logging.info(
            "Keine Daten erhalten oder stdin geschlossen (Extension hat Verbindung getrennt)."
        )
        return None

    message_length = struct.unpack("=I", raw_length)[0]
    logging.debug(f"Erwartete Nachrichtengröße: {message_length} Bytes")

    encoded_message = sys.stdin.buffer.read(message_length)
    message = json.loads(encoded_message)
    logging.info(f"Nachricht empfangen: {message}")
    return message


def send_file_data():
    """Liest die Datei aus und sendet ihren Inhalt an die Extension."""
    logging.info(f"Versuche Datei zu lesen: {FILE_PATH}")

    if os.path.exists(FILE_PATH):
        try:
            with open(FILE_PATH, "rb") as f:
                content = f.read()
                encoded_file = base64.b64encode(content).decode("utf-8")

            logging.info(
                f"Datei erfolgreich gelesen ({len(content)} Bytes). Sende an Extension..."
            )
            send_message({
                "status": "success",
                "filename": os.path.basename(FILE_PATH),
                "data": encoded_file,
            })
        except Exception as e:
            error_msg = f"Dateifehler beim Lesen: {str(e)}"
            logging.error(error_msg, exc_info=True)
            send_message({"status": "error", "message": error_msg})
    else:
        error_msg = f"Datei nicht gefunden unter: {FILE_PATH}"
        logging.warning(error_msg)
        send_message({"status": "error", "message": error_msg})


def handle_request(msg):
    """Verarbeitet nachfolgend eingehende Kommandos der Extension."""
    if not msg:
        return

    action = msg.get("action")
    logging.info(f"Verarbeite Action: '{action}'")

    if action in ["connect", "get_file"]:
        send_file_data()
    else:
        warn_msg = f"Unbekannte Action empfangen: {action}"
        logging.warning(warn_msg)
        send_message({"status": "error", "message": warn_msg})


def main():
    logging.info("Start")
    try:
        while True:
            message = read_message()
            if message is None:
                break
            handle_request(message)
    except Exception as e:
        logging.critical(f"Unerwarteter Hauptfehler: {e}", exc_info=True)
    finally:
        logging.info("=== Native Messaging Host beendet ===")


if __name__ == "__main__":
    main()