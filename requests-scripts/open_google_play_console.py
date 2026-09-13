import webbrowser

URL = "https://play.google.com/console/u/0/developers/9102135194134726659/orders"

# Pfad zu Chromium anpassen (Linux-Standard: 'chromium' oder 'chromium-browser')
# Unter Windows z.B.: "C:/Program Files/Chromium/Application/chromium.exe %s"
# Unter macOS z.B.: "open -a /Applications/Chromium.app %s"
chromium_path = "chromium %s"

try:
    browser = webbrowser.get(chromium_path)
    browser.open(URL)
except webbrowser.Error:
    print("Chromium konnte nicht gefunden werden. Fallback auf Standardbrowser:")
    webbrowser.open(URL)