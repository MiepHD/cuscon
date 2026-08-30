# --- Python-Installation & Umgebung prüfen ---
ensure_python() {
    if ! command -v python3 &> /dev/null; then
        echo "--> Python3 was not found. Attempting automatic installation..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y python3 python3-pip python3-pil curl
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y python3 python3-pip python3-pillow curl
        elif command -v brew &> /dev/null; then
            brew install python3 pillow curl
        else
            echo "Error: Package manager not recognized. Please install Python3 manually."
            exit 1
        fi
    fi
}

# --- Gradle-Installation prüfen & ggf. via Snap/SDKMAN/Brew installieren ---
ensure_gradle() {
    if command -v gradle &> /dev/null; then
        return 0
    fi

    echo "--> System Gradle was not found. Attempting automatic installation..."
    if command -v snap &> /dev/null; then
        echo "--> Installing Gradle via Snap..."
        sudo snap install gradle --classic
    elif command -v sdk &> /dev/null; then
        echo "--> Installing Gradle via SDKMAN!..."
        sdk install gradle
    elif command -v brew &> /dev/null; then
        echo "--> Installing Gradle via Brew..."
        brew install gradle
    elif command -v apt-get &> /dev/null; then
        echo "--> Installing Gradle via apt..."
        sudo apt-get update && sudo apt-get install -y gradle
    elif command -v dnf &> /dev/null; then
        echo "--> Installing Gradle via dnf..."
        sudo dnf install -y gradle
    elif command -v choco &> /dev/null; then
        echo "--> Installing Gradle via choco..."
        choco install gradle
    else
        echo "Error: No suitable package manager found for Gradle."
        echo "Please install Gradle manually (e.g., via Snap: 'sudo snap install gradle --classic')."
        return 1
    fi
}
