import os
import re
import math
import xml.etree.ElementTree as ET
from PIL import Image, ImageDraw, ImageFont

# ==========================================
# Pfad- und Konfigurations-Einstellungen
# ==========================================
BUILD_GRADLE_PATH = "build.gradle"                    # Oder z.B. "app/build.gradle"
DRAWABLE_XML_PATH = "src/main/res/xml/drawable.xml"   # Oder wo die XML liegt
NODPI_DIR = "src/foss/res/drawable-nodpi"             # Ordner mit den WebP-Dateien
OUTPUT_DIR = "build/instagram_posts"       # Ausgabe-Ordner
LOGO_FILENAME = "cuscon.webp"        # Name der Logo-Datei im nodpi-Ordner
CAPTION_FILENAME = "instagram_caption.txt"  # Name der Textdatei für die Caption
CHANGELOG_DIR = os.path.join("..", "metadata", "en-US", "changelogs")

# Design-Einstellungen (1080x1080 für Instagram)
CANVAS_SIZE = (1080, 1080)

# Hex-Farben für den Hintergrund (#b084fe & #767bf2)
COLOR_PURPLE = (176, 132, 254)              # #b084fe
COLOR_BLUE = (118, 123, 242)                # #767bf2

TEXT_COLOR = (255, 255, 255)
SUBTEXT_COLOR = (240, 240, 255)

# Layout-Einstellungen
MAX_ICONS_PER_POST = 16                     # 4x4 Grid pro Post
ICON_SIZE = 140                             # Größe jedes Icons in px
GRID_SPACING_X = 60
GRID_SPACING_Y = 60
MARGIN_TOP = 220                            # Platz für die Überschrift oben


def get_version_info(gradle_path):
    """Liest versionName und versionCode aus der build.gradle aus."""
    version_name = "v1.0.0"
    version_code = "1"

    if not os.path.exists(gradle_path):
        print(f"WARNING: {gradle_path} not found. Using defaults ({version_name}, code {version_code}).")
        return version_name, version_code

    with open(gradle_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Sucht nach versionName "x.y.z" oder versionName 'x.y.z'
    match_name = re.search(r'versionName\s+["\']([^"\']+)["\']', content)
    if match_name:
        version_name = f"v{match_name.group(1)}"
    else:
        print("WARNING: versionName not found in build.gradle.")

    # Sucht nach versionCode 123
    match_code = re.search(r'versionCode\s+(\d+)', content)
    if match_code:
        version_code = match_code.group(1)
    else:
        print("WARNING: versionCode not found in build.gradle.")

    return version_name, version_code


def parse_new_icons(xml_path):
    """Liest nur die Items aus der Kategorie 'New Icons' aus der drawable.xml."""
    if not os.path.exists(xml_path):
        raise FileNotFoundError(f"XML file {xml_path} not found.")

    tree = ET.parse(xml_path)
    root = tree.getroot()

    new_icons = []
    in_new_icons_category = False

    for elem in root:
        if elem.tag == "category":
            title = elem.attrib.get("title", "")
            if title == "New Icons":
                in_new_icons_category = True
            else:
                in_new_icons_category = False

        elif elem.tag == "item" and in_new_icons_category:
            drawable_name = elem.attrib.get("drawable")
            if drawable_name:
                new_icons.append(drawable_name)

    return new_icons


def create_gradient_background(width, height, color1, color2):
    """Erstellt einen diagonalen Farbverlauf zwischen den beiden Hex-Farben."""
    base = Image.new("RGBA", (width, height))
    draw = ImageDraw.Draw(base)

    r1, g1, b1 = color1
    r2, g2, b2 = color2

    # Diagonaler Farbverlauf für einen dynamischeren Look
    for y in range(height):
        for x in range(width):
            factor = (x + y) / (width + height)
            r = int(r1 + (r2 - r1) * factor)
            g = int(g1 + (g2 - g1) * factor)
            b = int(b1 + (b2 - b1) * factor)
            draw.point((x, y), fill=(r, g, b, 255))

    return base


def load_font(size):
    """Versucht eine passende System-Schriftart zu laden oder nutzt Standard."""
    font_paths = [
        "arial.ttf",
        "DejaVuSans.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for path in font_paths:
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            continue
    return ImageFont.load_default()


def generate_post_image(icon_batch, remaining_icons_count, version_str, logo_img):
    """Generiert ein einzelnes Instagram-Post-Bild."""
    width, height = CANVAS_SIZE
    img = create_gradient_background(width, height, COLOR_PURPLE, COLOR_BLUE)
    draw = ImageDraw.Draw(img)

    # 1. Überschrift auf Englisch
    title_font = load_font(54)
    title_text = f"New in version {version_str}"
    draw.text((width / 2, 110), title_text, fill=TEXT_COLOR, font=title_font, anchor="mm")

    # 2. Icon-Grid berechnen
    num_icons = len(icon_batch)
    cols = min(4, math.ceil(math.sqrt(num_icons)))
    rows = math.ceil(num_icons / cols)

    grid_width = cols * ICON_SIZE + (cols - 1) * GRID_SPACING_X
    grid_height = rows * ICON_SIZE + (rows - 1) * GRID_SPACING_Y

    start_x = (width - grid_width) // 2
    start_y = MARGIN_TOP + ((height - MARGIN_TOP - 160) - grid_height) // 2

    # 3. Icons zeichnen
    for i, icon_name in enumerate(icon_batch):
        r = i // cols
        c = i % cols

        x = start_x + c * (ICON_SIZE + GRID_SPACING_X)
        y = start_y + r * (ICON_SIZE + GRID_SPACING_Y)

        icon_path = os.path.join(NODPI_DIR, f"{icon_name}.webp")
        if os.path.exists(icon_path):
            try:
                icon_img = Image.open(icon_path).convert("RGBA")
                icon_img = icon_img.resize((ICON_SIZE, ICON_SIZE), Image.Resampling.LANCZOS)
                img.paste(icon_img, (x, y), icon_img)
            except Exception as e:
                print(f"Error loading {icon_path}: {e}")
        else:
            print(f"Notice: Icon file not found: {icon_path}")

    # 4. Logo UNTEN LINKS platzieren
    padding = 50
    if logo_img:
        logo_w, logo_h = logo_img.size
        target_h = 70
        target_w = int(logo_w * (target_h / logo_h))
        logo_resized = logo_img.resize((target_w, target_h), Image.Resampling.LANCZOS)

        logo_x = padding
        logo_y = height - target_h - padding
        img.paste(logo_resized, (logo_x, logo_y), logo_resized)

    # 5. Pfeil & verbleibende Icons UNTEN RECHTS platzieren
    if remaining_icons_count > 0:
        arrow_font = load_font(34)
        arrow_text = f"+{remaining_icons_count} more →"

        arrow_x = width - padding
        arrow_y = height - padding - 35
        draw.text((arrow_x, arrow_y), arrow_text, fill=SUBTEXT_COLOR, font=arrow_font, anchor="rm")

    return img


def get_changelog_content(version_code):
    """Liest den Text aus metadata/en-US/changelogs/<versionCode>.txt."""
    changelog_path = os.path.join(CHANGELOG_DIR, f"{version_code}.txt")
    if os.path.exists(changelog_path):
        with open(changelog_path, "r", encoding="utf-8") as f:
            content = f.read().strip()
            print(f"Changelog loaded from: {changelog_path}")
            return content
    else:
        print(f"WARNING: Changelog file not found at '{changelog_path}'.")
        return "Check out the latest updates and newly added icons!"


def generate_caption_file(version_str, version_code, output_path):
    """Erstellt die Instagram-Caption mit dem Changelog-Text aus der TXT-Datei."""
    changelog_text = get_changelog_content(version_code)

    caption = f"""🚀 New Update Released! ({version_str})

Swipe through the post to check out all the new icons! 👉

{changelog_text}

Thank you for your support and feedback!

#IconPack #AndroidCustomization #AppIcons #SetupInspiration #Cuscon
"""

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(caption)

    print(f"Caption saved to: {output_path}")


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Daten laden
    version_str, version_code = get_version_info(BUILD_GRADLE_PATH)
    print(f"Extracted version: {version_str} (code: {version_code})")

    icons = parse_new_icons(DRAWABLE_XML_PATH)
    print(f"Found {len(icons)} icons under 'New Icons'.")

    if not icons:
        print("No icons found under 'New Icons'. Aborting.")
        return

    # Cuscon Logo laden
    logo_path = os.path.join(NODPI_DIR, LOGO_FILENAME)
    logo_img = None
    if os.path.exists(logo_path):
        logo_img = Image.open(logo_path).convert("RGBA")
        print("Cuscon logo loaded successfully.")
    else:
        print(f"WARNING: Logo not found at '{logo_path}'.")

    # In Batches aufteilen und Posts generieren
    total_icons = len(icons)
    total_pages = math.ceil(total_icons / MAX_ICONS_PER_POST)

    for i in range(total_pages):
        batch = icons[i * MAX_ICONS_PER_POST : (i + 1) * MAX_ICONS_PER_POST]

        # Berechnen, wie viele Icons danach noch folgen
        icons_processed_so_far = (i + 1) * MAX_ICONS_PER_POST
        remaining_icons_count = max(0, total_icons - icons_processed_so_far)

        post_img = generate_post_image(batch, remaining_icons_count, version_str, logo_img)

        output_filename = os.path.join(OUTPUT_DIR, f"instagram_post_{i + 1}.png")
        post_img.save(output_filename, "PNG")
        print(f"Post saved: {output_filename}")

    # Caption .txt Datei ausgeben
    caption_path = os.path.join(OUTPUT_DIR, CAPTION_FILENAME)
    generate_caption_file(version_str, version_code, caption_path)

    print("\nDone! All Instagram posts and the caption text file have been created.")


if __name__ == "__main__":
    main()