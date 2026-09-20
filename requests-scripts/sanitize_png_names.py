import os
import sys
import re
import random
import string
import xml.etree.ElementTree as ET

target_folder = sys.argv[1]

def generate_unique_hex_name():
    hex_chars = "0123456789abcdef"
    return "_" + ''.join(random.choices(hex_chars, k=32))

xml_files = [
    os.path.join(target_folder, "appfilter.xml"),
    os.path.join(target_folder, "theme_resources.xml")
]

if not os.path.exists(target_folder):
    sys.exit(0)

# 1. Wir durchsuchen die XML-Dateien nach allen definierten Icons
drawables = set()

for xml_path in xml_files:
    if not os.path.isfile(xml_path):
        continue
    try:
        with open(xml_path, "r", encoding="utf-8") as f:
            content = f.read()
            # Sucht nach allen Werten in drawable="..." und image="..."
            matches = re.findall(r'(?:drawable|image)="([^"]+)"', content)
            drawables.update(matches)
    except Exception as e:
        print(f"[!] Fehler beim Lesen von {xml_path}: {e}")

# 2. Prüfen jedes in den XMLs gefundenen Eintrags auf Dateisystem-Ebene
for name in drawables:
    # Prüfen, ob der Name ungültige Zeichen oder führende Zahlen enthält
    if re.search(r'[^a-z0-9_]', name) or re.match(r'^[0-9]', name):
        
        # Versuche die zugehörige PNG-Datei auf der Festplatte zu finden
        expected_filename = f"{name}.png"
        png_path = os.path.join(target_folder, expected_filename)

        # Fallback-Suche, falls das Encoding im FS leicht abweicht
        found_file = None
        if os.path.exists(png_path):
            found_file = expected_filename
        else:
            # Suche nach Byte-Entsprechung im Ordner
            for file in os.listdir(target_folder):
                if file.lower().endswith(".png"):
                    # Vergleiche normalisierte Pfade
                    if os.path.exists(os.path.join(target_folder, file)) and file.startswith(name[:3]):
                        found_file = file
                        break

        if found_file:
            print(f"--> Invalid name in XML/FS detected: '{name}' (File: '{found_file}')")
            new_hex_name = generate_unique_hex_name()
            new_filename = f"{new_hex_name}.png"

            # 1. Datei auf der Festplatte umbenennen
            old_full_path = os.path.join(target_folder, found_file)
            new_full_path = os.path.join(target_folder, new_filename)
            
            try:
                os.rename(old_full_path, new_full_path)
                print(f"  \033[0;32m[✓]\033[0m Automatic renaming file: '{found_file}' -> '{new_filename}'")
            except Exception as e:
                print(f"  [!] Fehler beim Umbenennen der Datei: {e}")
                continue

            # 2. In allen XML-Dateien exakt nach dem String 'name' suchen und ersetzen
            for xml_path in xml_files:
                if os.path.isfile(xml_path):
                    try:
                        with open(xml_path, "r", encoding="utf-8") as f:
                            xml_content = f.read()

                        # Exakter Austausch von Name in XMLs
                        updated_xml = xml_content.replace(f'"{name}"', f'"{new_hex_name}"')

                        if updated_xml != xml_content:
                            with open(xml_path, "w", encoding="utf-8") as f:
                                f.write(updated_xml)
                            print(f"  \033[0;32m[✓]\033[0m XML updated: {os.path.basename(xml_path)}")
                    except Exception as e:
                        print(f"  [!] Fehler beim Schreiben in {os.path.basename(xml_path)}: {e}")