#!/bin/bash
set -e

# Pfade definieren (analog zu $projectDir)
PROJECT_DIR="$(pwd)"
SRC_DIR="$PROJECT_DIR/src/main/res/xml"
ASSETS_DIR="$PROJECT_DIR/src/main/assets"

# 1. Task: sortDrawable ausführen
echo "Running sort_drawable.py..."
python3 sort_drawable.py

# 2. Task: finishXMLs (Dateien kopieren)
echo "Copy xml files to assets dir..."
mkdir -p "$ASSETS_DIR"

cp "$SRC_DIR/appfilter.xml" "$ASSETS_DIR/"
cp "$SRC_DIR/drawable.xml" "$ASSETS_DIR/"

echo "Finished!"
