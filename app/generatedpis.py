import os
from PIL import Image
from tqdm import tqdm

# Pfad zu deinem res-Ordner
RES_DIR = "src/play/res"
NODPI_DIR = os.path.join("src/foss/res", "drawable-nodpi")

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

    errors = []

    # Fortschrittsbalken über alle Dateien in nodpi
    print(f"Verarbeite {expected_count} WebP-Icons...\n")
    for filename in tqdm(source_files, desc="Skaliere Icons", unit="icon"):
        file_path = os.path.join(NODPI_DIR, filename)

        # Prüfen, welche Ordner die Datei noch benötigen
        missing_folders = []
        for folder_name in ICON_SIZES.keys():
            output_path = os.path.join(RES_DIR, folder_name, filename)
            if not os.path.exists(output_path):
                missing_folders.append(folder_name)

        # Wenn die Datei bereits in allen Zielordnern existiert, überspringen
        if not missing_folders:
            continue

        try:
            with Image.open(file_path) as img:
                img = img.convert("RGBA")

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

        except Exception as e:
            errors.append((filename, str(e)))

    # Eventuell aufgetretene Einzelfehler nach dem Balken ausgeben
    if errors:
        print("\nFolgende Dateien konnten nicht verarbeitet werden:")
        for fn, err in errors:
            print(f"  ❌ {fn}: {err}")

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