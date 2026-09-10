import os
from PIL import Image

# Pfad zu deinem res-Ordner (anpassen, falls notwendig)
RES_DIR = "src/main/res"
NODPI_DIR = os.path.join(RES_DIR, "drawable-nodpi")

# Feste Standard-Icon-Größen in Pixeln (Breite x Höhe)
ICON_SIZES = {
    "drawable-mdpi": (48, 48),
    "drawable-hdpi": (72, 72),
    "drawable-xhdpi": (96, 96),
    "drawable-xxhdpi": (144, 144),
    "drawable-xxxhdpi": (192, 192),
}

def count_webp_files(folder_path):
    """Zählt alle .webp Dateien in einem Ordner."""
    if not os.path.exists(folder_path):
        return 0
    return len([f for f in os.listdir(folder_path) if f.lower().endswith(".webp")])

def generate_webp_icons():
    if not os.path.exists(NODPI_DIR):
        print(f"Fehler: Ordner '{NODPI_DIR}' existiert nicht.")
        return

    # Zielordner erstellen
    for folder_name in ICON_SIZES.keys():
        os.makedirs(os.path.join(RES_DIR, folder_name), exist_ok=True)

    # Nur WebP-Dateien einlesen
    source_files = [f for f in os.listdir(NODPI_DIR) if f.lower().endswith(".webp")]
    expected_count = len(source_files)

    if expected_count == 0:
        print(f"Keine .webp-Dateien in '{NODPI_DIR}' gefunden.")
        return

    print(f"Gefundene WebP-Icons in nodpi: {expected_count}. Starte Prüfung...\n")

    for filename in source_files:
        file_path = os.path.join(NODPI_DIR, filename)

        # Prüfen, welche Ordner die Datei noch benötigen
        missing_folders = []
        for folder_name in ICON_SIZES.keys():
            output_path = os.path.join(RES_DIR, folder_name, filename)
            if not os.path.exists(output_path):
                missing_folders.append(folder_name)

        # Wenn die Datei in allen Zielordnern existiert, komplett überspringen
        if not missing_folders:
            print(f"➜ Übersprungen (bereits vorhanden): {filename}")
            continue

        try:
            with Image.open(file_path) as img:
                # Sicherstellen, dass das Bild im RGBA-Modus geladen wird
                img = img.convert("RGBA")

                # Nur für die Ordner verarbeiten, in denen die Datei fehlt
                for folder_name in missing_folders:
                    size = ICON_SIZES[folder_name]
                    target_dir = os.path.join(RES_DIR, folder_name)
                    output_path = os.path.join(target_dir, filename)

                    # Bild skalieren
                    resized_img = img.resize(size, Image.Resampling.LANCZOS)

                    # Hard 1-Bit Alpha Enforcement: Reines 0% oder 100% Alpha erzwingen
                    r, g, b, alpha = resized_img.split()
                    strict_alpha = alpha.point(lambda p: 255 if p > 128 else 0)
                    resized_img = Image.merge("RGBA", (r, g, b, strict_alpha))

                    # Verlustfrei als WebP speichern
                    resized_img.save(output_path, "WEBP", lossless=True)

                print(f"✓ Verarbeitet ({len(missing_folders)} Ordner befüllt): {filename}")
        except Exception as e:
            print(f"✕ Fehler bei {filename}: {e}")

    # Validation: Dateianzahl in allen Zielordnern prüfen
    print("\n--- Überprüfe Dateianzahlen ---")
    all_matched = True

    for folder_name in ICON_SIZES.keys():
        target_dir = os.path.join(RES_DIR, folder_name)
        file_count = count_webp_files(target_dir)

        if file_count != expected_count:
            all_matched = False
            print(f"❌ Fehler in '{folder_name}': {file_count} von {expected_count} WebP-Dateien vorhanden.")
        else:
            print(f"✓ '{folder_name}': {file_count} Dateien OK.")

    # Finale Statusausgabe
    print("\n----------------------------------")
    if all_matched:
        print(" SUCCESS: Alle DPI-Ordner enthalten exakt dieselbe Anzahl an WebP-Dateien!")
    else:
        print(" FAILED: Die Generierung war unvollständig. Bitte Fehler oben prüfen.")

if __name__ == "__main__":
    generate_webp_icons()