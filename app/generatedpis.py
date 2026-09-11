import os
import shutil
from collections import defaultdict
from PIL import Image
from tqdm import tqdm

# Pfad zu deinem res-Ordner
RES_DIR = "src/play/res"
NODPI_DIR = os.path.join("src/foss/res", "drawable-nodpi")
TARGET_NODPI_DIR = os.path.join(RES_DIR, "drawable-nodpi")

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

def process_single_icon(file_path, output_path, size):
    """Skaliert ein Icon auf 90% Qualität, erzwingt 1-Bit Alpha und leert RGB-Daten bei A=0."""
    with Image.open(file_path) as img:
        img = img.convert("RGBA")

        # Bild skalieren
        resized_img = img.resize(size, Image.Resampling.LANCZOS)

        # Mit 90% Bildqualität speichern
        resized_img.save(output_path, "WEBP", quality=90, alpha=0)

def generate_webp_icons():
    if not os.path.exists(NODPI_DIR):
        print(f"Fehler: Ordner '{NODPI_DIR}' existiert nicht.")
        return

    # Zielordner erstellen
    for folder_name in ICON_SIZES.keys():
        os.makedirs(os.path.join(RES_DIR, folder_name), exist_ok=True)
    os.makedirs(TARGET_NODPI_DIR, exist_ok=True)

    # Nur WebP-Dateien einlesen
    source_files = [f for f in os.listdir(NODPI_DIR) if f.lower().endswith(".webp")]
    expected_count = len(source_files)

    if expected_count == 0:
        print(f"Keine .webp-Dateien in '{NODPI_DIR}' gefunden.")
        return

    errors = []
    fallback_copies_per_folder = defaultdict(int)
    nodpi_redirects_count = 0

    print(f"Verarbeite {expected_count} WebP-Icons...\n")
    for filename in tqdm(source_files, desc="Skaliere Icons", unit="icon"):
        file_path = os.path.join(NODPI_DIR, filename)
        original_size_bytes = os.path.getsize(file_path)

        # Prüfen, ob MDPI bereits skalierbar ist oder nach dem Skalieren größer als das Original wird
        temp_mdpi_path = os.path.join(RES_DIR, "drawable-mdpi", f"temp_{filename}")
        
        try:
            # Test-Skalierung für die kleinste Dichte (mdpi)
            process_single_icon(file_path, temp_mdpi_path, ICON_SIZES["drawable-mdpi"])
            mdpi_scaled_size = os.path.getsize(temp_mdpi_path)
            
            # Aufräumen der temporären Test-Datei
            if os.path.exists(temp_mdpi_path):
                os.remove(temp_mdpi_path)

            # Wenn selbst das mdpi-Icon größer als das Original ist -> kopieren nach target drawable-nodpi
            if mdpi_scaled_size >= original_size_bytes:
                target_nodpi_path = os.path.join(TARGET_NODPI_DIR, filename)
                shutil.copy2(file_path, target_nodpi_path)
                print(f"\n⚠️  [nodpi]: '{filename}' ist auf mdpi größer ({mdpi_scaled_size} B) als das Original ({original_size_bytes} B). Kopiere direkt nach {TARGET_NODPI_DIR}.")
                nodpi_redirects_count += 1
                continue

            # Regulärer Ablauf für die übrigen DPI-Ordner
            for folder_name, size in ICON_SIZES.items():
                target_dir = os.path.join(RES_DIR, folder_name)
                output_path = os.path.join(target_dir, filename)

                if os.path.exists(output_path):
                    continue

                process_single_icon(file_path, output_path, size)
                scaled_size_bytes = os.path.getsize(output_path)

                # Prüfen, ob das skalierte Bild größer als das Original ist
                if scaled_size_bytes >= original_size_bytes:
                    print(f"\n⚠️  [{folder_name}]: Skaliertes Bild '{filename}' ({scaled_size_bytes} B) ist größer als Original ({original_size_bytes} B). Kopiere Originalbild.")
                    shutil.copy2(file_path, output_path)
                    fallback_copies_per_folder[folder_name] += 1

        except Exception as e:
            errors.append((filename, str(e)))

    # Eventuell aufgetretene Einzelfehler ausgeben
    if errors:
        print("\nFolgende Dateien konnten nicht verarbeitet werden:")
        for fn, err in errors:
            print(f"  ❌ {fn}: {err}")

    # Zusammenfassung anzeigen
    print("\n--- Überprüfe Dateianzahlen & Statistik ---")

    for folder_name in ICON_SIZES.keys():
        target_dir = os.path.join(RES_DIR, folder_name)
        file_count = count_webp_files(target_dir)
        print(f"ℹ️ '{folder_name}': {file_count} Dateien.")

    target_nodpi_count = count_webp_files(TARGET_NODPI_DIR)
    print(f"ℹ️ 'drawable-nodpi' (Ziel): {target_nodpi_count} Dateien.")

    total_fallbacks = sum(fallback_copies_per_folder.values())
    print("\n----------------------------------")
    print(f"  Unskalierte Fallback-Kopien gesamt: {total_fallbacks}")
    for folder_name in ICON_SIZES.keys():
        count = fallback_copies_per_folder[folder_name]
        print(f"    - {folder_name}: {count}")
    print(f"  Direkt nach 'drawable-nodpi' kopierte Icons: {nodpi_redirects_count}")
    print("----------------------------------")

if __name__ == "__main__":
    generate_webp_icons()