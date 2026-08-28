import sys
from PIL import Image

src_path, dest_path = sys.argv[1], sys.argv[2]
try:
    with Image.open(src_path) as img:
        width, height = img.size
        if width != height:
            print(f"  [!] ERROR: '{src_path}' is not square ({width}x{height})! Skipped.")
            sys.exit(1)
        if width != 256 or height != 256:
            img = img.resize((256, 256), Image.Resampling.LANCZOS)
            print(f"  [✓] Scale to 256x256: {src_path}")
        img.save(dest_path, "WEBP", quality=100, alpha_quality=0)
        print(f"  [✓] Created WEBP: {dest_path}")
except Exception as e:
    print(f"  [!] Error while processing '{src_path}': {e}")
    sys.exit(1)