# --- Python-Installation & Umgebung prüfen ---
ensure_python() {
    if ! command -v python3 &> /dev/null; then
        echo -e "${YELLOW}--> Python3 was not found. Attempting automatic installation...${NC}"
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y python3 python3-pip python3-pil curl
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y python3 python3-pip python3-pillow curl
        elif command -v brew &> /dev/null; then
            brew install python3 pillow curl
        else
            echo -e "${RED}Error: Package manager not recognized. Please install Python3 manually.${NC}"
            exit 1
        fi
    fi
}

# --- Gradle-Installation prüfen & ggf. via Snap/SDKMAN/Brew installieren ---
ensure_gradle() {
    if command -v gradle &> /dev/null; then
        return 0
    fi

    echo -e "${YELLOW}--> System Gradle was not found. Attempting automatic installation...${NC}"
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
        echo -e "${RED}Error: No suitable package manager found for Gradle.${NC}"
        echo "Please install Gradle manually (e.g., via Snap: 'sudo snap install gradle --classic')."
        return 1
    fi
}
