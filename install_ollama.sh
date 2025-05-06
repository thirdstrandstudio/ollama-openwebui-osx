#!/bin/bash
set -euo pipefail

# ==========================================================================
# Ollama + Open WebUI Installation Script for macOS Sequoia 15.4.1
# Compatible with Apple Silicon (M-series) processors
# ==========================================================================

# Handle --help
if [[ "${1:-}" == "--help" ]]; then
    echo "Usage: ./install_ollama.sh"
    echo "This script installs Ollama and Open WebUI on macOS Sequoia 15.4.1 (Apple Silicon)."
    exit 0
fi

# Color variables for better visual feedback
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner function
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "  ___ _ _                               ___                  _ _ _ ___ ___   ___ _        _ _ "
    echo " / _ \| | |__ _ _ __  __ _   ___       / _ \ _ __ ___ _ __  | | | | __| _ ) | _ \ |_  ___| | |"
    echo "| (_) | | / _\` | '  \/ _\` | |___| +   | (_) | '_ / -_) '_ \ | | | | _|| _ \ |  _/ ' \(_-<| | |"
    echo " \___/|_|_\__,_|_|_|_\__,_|           \___/| .__\___| .__/  \___/|___|___/ |_| |_||_/__/|_|_|"
    echo "                                           |_|    |_|                                         "
    echo -e "${NC}"
    echo -e "${YELLOW}==== Installation Script for macOS Sequoia 15.4.1 (Apple Silicon) ====${NC}"
    echo ""
}

# Function to check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check if we're running on Apple Silicon
check_apple_silicon() {
    if [[ $(uname -m) != "arm64" ]]; then
        echo -e "${RED}This script is optimized for Apple Silicon (M-series) Macs.${NC}"
        echo -e "${YELLOW}You appear to be running on $(uname -m). Some features may not work as expected.${NC}"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${RED}Installation aborted.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓ Apple Silicon detected.${NC}"
    fi
}

# Function to check system requirements
check_system_requirements() {
    echo -e "${BLUE}Checking system requirements...${NC}"
    
    # Check macOS version
    OS_VERSION=$(sw_vers -productVersion)
    if [[ "$OS_VERSION" != "15.4.1" ]]; then
        echo -e "${YELLOW}⚠️  Warning: This script was designed for macOS Sequoia 15.4.1, but you're running $OS_VERSION${NC}"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${RED}Installation aborted.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓ macOS version 15.4.1 detected.${NC}"
    fi
    
    # Check available disk space (minimum 20GB recommended)
    AVAILABLE_SPACE=$(df -k / | awk 'NR==2 {print int($4 / 1024 / 1024)}')
    if (( AVAILABLE_SPACE < 20 )); then
        echo -e "${YELLOW}⚠️  Warning: Less than 20GB available disk space detected (${AVAILABLE_SPACE} GB)${NC}"
        echo -e "${YELLOW}Large language models require significant disk space.${NC}"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${RED}Installation aborted.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓ Sufficient disk space available: ${AVAILABLE_SPACE} GB${NC}"
    fi
    
    # Check available RAM (minimum 8GB recommended)
    TOTAL_RAM=$(( $(sysctl -n hw.memsize) / 1073741824 ))
    if (( TOTAL_RAM < 8 )); then
        echo -e "${YELLOW}⚠️  Warning: Less than 8GB RAM detected (${TOTAL_RAM} GB)${NC}"
        echo -e "${YELLOW}Large language models perform better with more RAM.${NC}"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${RED}Installation aborted.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓ Sufficient RAM available: ${TOTAL_RAM} GB${NC}"
    fi
}

# Function to install or update Homebrew
install_homebrew() {
    echo -e "${BLUE}Checking for Homebrew...${NC}"
    
    if command_exists brew; then
        echo -e "${GREEN}✓ Homebrew is already installed.${NC}"
        echo -e "${BLUE}Updating Homebrew...${NC}"
        brew update
    else
        echo -e "${YELLOW}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
    
    echo -e "${GREEN}✓ Homebrew is ready.${NC}"
}

# Function to install dependencies
install_dependencies() {
    echo -e "${BLUE}Installing dependencies...${NC}"
    
    brew install curl wget git python@3.11 node docker
    
    if ! command_exists docker; then
        echo -e "${YELLOW}Installing Docker Desktop...${NC}"
        brew install --cask docker
        
        echo -e "${YELLOW}Please open Docker Desktop manually after installation to complete setup.${NC}"
        echo -e "${YELLOW}After Docker is running, press any key to continue...${NC}"
        read -n 1 -s
    else
        echo -e "${GREEN}✓ Docker is already installed.${NC}"
    fi
    
    if ! docker info &>/dev/null; then
        echo -e "${YELLOW}Docker is not running. Please start Docker Desktop and press any key to continue...${NC}"
        read -n 1 -s
        
        if ! docker info &>/dev/null; then
            echo -e "${RED}Docker is still not running. Please start Docker Desktop manually.${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✓ All dependencies installed.${NC}"
}

# Function to install Ollama
install_ollama() {
    echo -e "${BLUE}Installing Ollama...${NC}"

    if command_exists ollama; then
        CURRENT_VERSION=$(ollama --version | cut -d ' ' -f 3)
        echo -e "${GREEN}✓ Ollama is already installed (version $CURRENT_VERSION).${NC}"

        read -p "Do you want to reinstall/update Ollama? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Keeping current Ollama installation.${NC}"
            return
        fi

        if pgrep -x "ollama" > /dev/null; then
            echo -e "${YELLOW}Stopping running Ollama instance...${NC}"
            pkill -f ollama
        fi
    fi

    BACKUP_DIR="$HOME/ollama_backup_$(date +%Y%m%d_%H%M%S)"
    if [ -d "$HOME/.ollama" ]; then
        echo -e "${YELLOW}Creating backup of existing Ollama data at $BACKUP_DIR${NC}"
        mkdir -p "$BACKUP_DIR"
        cp -R "$HOME/.ollama" "$BACKUP_DIR/"
    fi

    echo -e "${YELLOW}Installing Ollama via Homebrew...${NC}"

    if brew list ollama &>/dev/null; then
        brew upgrade ollama
    else
        brew install ollama
    fi

    if command_exists ollama; then
        NEW_VERSION=$(ollama --version | cut -d ' ' -f 3)
        echo -e "${GREEN}✓ Ollama installed successfully (version $NEW_VERSION).${NC}"
    else
        echo -e "${RED}Ollama installation failed via Homebrew.${NC}"
        exit 1
    fi

    mkdir -p "$HOME/.ollama"

    cat > "$HOME/.ollama/config.json" << EOL
{
    "gpu_layers": -1,
    "num_ctx": 8192,
    "num_thread": 8,
    "num_gpu": 1,
    "numa": false,
    "log_level": "warn"
}
EOL

    echo -e "${GREEN}✓ Created optimized configuration for Apple Silicon.${NC}"
}


# Function to install Open WebUI
install_openwebui() {
    echo -e "${BLUE}Installing Open WebUI...${NC}"
    
    if docker ps -a | grep -q "open-webui"; then
        echo -e "${GREEN}✓ Open WebUI is already installed as a Docker container.${NC}"
        read -p "Do you want to reinstall/update Open WebUI? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Keeping current Open WebUI installation.${NC}"
            return
        fi
        
        echo -e "${YELLOW}Stopping and removing existing Open WebUI container...${NC}"
        docker stop open-webui
        docker rm open-webui
    fi

    mkdir -p "$HOME/.openwebui"

    echo -e "${YELLOW}Pulling latest Open WebUI Docker image...${NC}"
    docker pull ghcr.io/open-webui/open-webui:main

    echo -e "${YELLOW}Creating Open WebUI container...${NC}"
    docker run -d \
        --name open-webui \
        -p 3000:8080 \
        -v "$HOME/.openwebui:/app/backend/data" \
        -e OLLAMA_API_BASE_URL=http://host.docker.internal:11434/api \
        --add-host=host.docker.internal:host-gateway \
        ghcr.io/open-webui/open-webui:main

    if docker ps | grep -q "open-webui"; then
        echo -e "${GREEN}✓ Open WebUI installed and running at http://localhost:3000${NC}"
    else
        echo -e "${RED}Open WebUI installation failed.${NC}"
        echo -e "${YELLOW}Docker logs:${NC}"
        docker logs open-webui
        exit 1
    fi
}

# Function to create convenience scripts and aliases
create_convenience_scripts() {
    echo -e "${BLUE}Creating convenience scripts...${NC}"
    mkdir -p "$HOME/ollama-scripts"

    # Start script
    cat > "$HOME/ollama-scripts/start-ollama-suite.sh" << 'EOS'
#!/bin/bash
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; NC='\033[0m'
echo -e "${BLUE}Starting Ollama...${NC}"
if pgrep -x "ollama" > /dev/null; then
    echo -e "${YELLOW}Ollama is already running.${NC}"
else
    nohup ollama serve > /dev/null 2>&1 &
    echo -e "${GREEN}✓ Ollama started.${NC}"
fi
echo -e "${BLUE}Starting Open WebUI...${NC}"
if docker ps | grep -q "open-webui"; then
    echo -e "${YELLOW}Open WebUI is already running.${NC}"
else
    docker start open-webui
    echo -e "${GREEN}✓ Open WebUI started.${NC}"
fi
echo -e "${GREEN}✓ Ollama suite is now running.${NC}"
echo -e "${BLUE}Access the Web UI at: ${GREEN}http://localhost:3000${NC}"
EOS

    # Stop script
    cat > "$HOME/ollama-scripts/stop-ollama-suite.sh" << 'EOS'
#!/bin/bash
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; NC='\033[0m'
echo -e "${BLUE}Stopping Open WebUI...${NC}"
docker stop open-webui || echo -e "${YELLOW}Open WebUI was not running.${NC}"
echo -e "${BLUE}Stopping Ollama...${NC}"
pkill -f ollama || echo -e "${YELLOW}Ollama was not running.${NC}"
echo -e "${GREEN}✓ Ollama suite has been stopped.${NC}"
EOS

    # Status script
    cat > "$HOME/ollama-scripts/status-ollama-suite.sh" << 'EOS'
#!/bin/bash
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; NC='\033[0m'
echo -e "${BLUE}Checking Ollama status...${NC}"
if pgrep -x "ollama" > /dev/null; then
    echo -e "${GREEN}✓ Ollama is running.${NC}"
    echo -e "${BLUE}Ollama version:${NC} $(ollama --version)"
else
    echo -e "${RED}✗ Ollama is not running.${NC}"
fi
echo -e "${BLUE}Checking Open WebUI status...${NC}"
if docker ps | grep -q "open-webui"; then
    echo -e "${GREEN}✓ Open WebUI is running.${NC}"
else
    echo -e "${RED}✗ Open WebUI is not running.${NC}"
fi
EOS

    # Backup script
    cat > "$HOME/ollama-scripts/backup-ollama.sh" << 'EOS'
#!/bin/bash
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; NC='\033[0m'
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/ollama_backup_$TIMESTAMP"
echo -e "${BLUE}Creating backup at $BACKUP_DIR...${NC}"
mkdir -p "$BACKUP_DIR"
cp -R "$HOME/.ollama" "$BACKUP_DIR/" 2>/dev/null || echo -e "${YELLOW}No Ollama data to back up.${NC}"
cp -R "$HOME/.openwebui" "$BACKUP_DIR/" 2>/dev/null || echo -e "${YELLOW}No WebUI data to back up.${NC}"
echo -e "${GREEN}✓ Backup complete.${NC}"
EOS

        # Model management script
    cat > "$HOME/ollama-scripts/manage-models.sh" << 'EOS'
#!/bin/bash
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

press_any_key() {
    echo
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}

display_models() {
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${CYAN}               INSTALLED MODELS${NC}"
    echo -e "${BLUE}===============================================${NC}"
    ollama list
    echo
}

download_model() {
    local model_name="$1"
    echo -e "${BLUE}Downloading model: ${model_name}${NC}"
    ollama pull "$model_name"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Model $model_name downloaded successfully.${NC}"
    else
        echo -e "${RED}✗ Failed to download model $model_name.${NC}"
    fi
    press_any_key
}

custom_model() {
    echo -e "${BLUE}Enter the name of the model you want to download (e.g., 'llama3:8b-instruct'):${NC}"
    read -p "> " CUSTOM_MODEL
    if [ -z "$CUSTOM_MODEL" ]; then
        echo -e "${RED}No model name provided.${NC}"
        return
    fi
    download_model "$CUSTOM_MODEL"
}

remove_model() {
    display_models
    echo -e "${BLUE}Enter the name of the model you want to remove:${NC}"
    read -p "> " MODEL
    if [ -z "$MODEL" ]; then
        echo -e "${RED}No model name provided.${NC}"
        return
    fi
    ollama rm "$MODEL"
    echo -e "${GREEN}✓ Model $MODEL removed.${NC}"
    press_any_key
}

update_models() {
    echo -e "${BLUE}Checking for model updates...${NC}"
    ollama list | awk 'NR>1 {print $1}' | while read model; do
        echo -e "${YELLOW}Updating $model...${NC}"
        ollama pull "$model"
    done
    echo -e "${GREEN}✓ All models updated.${NC}"
    press_any_key
}

show_menu() {
    while true; do
        clear
        echo -e "${CYAN}Ollama Model Manager${NC}"
        echo -e "${BLUE}1) Install Llama 3 (8B)"
        echo -e "2) Install Mistral"
        echo -e "3) Install CodeLlama:13b"
        echo -e "4) Install Custom Model"
        echo -e "5) Remove a Model"
        echo -e "6) Update All Models"
        echo -e "7) List Installed Models"
        echo -e "8) Exit${NC}"
        read -p "Choose an option: " choice
        case $choice in
            1) download_model "llama3:8b-instruct" ;;
            2) download_model "mistral" ;;
            3) download_model "codellama:13b" ;;
            4) custom_model ;;
            5) remove_model ;;
            6) update_models ;;
            7) display_models; press_any_key ;;
            8) exit 0 ;;
            *) echo -e "${RED}Invalid option.${NC}"; press_any_key ;;
        esac
    done
}

show_menu
EOS

    SHELL_RC="$HOME/.zshrc"
    if [[ "$SHELL" == *bash ]]; then
        SHELL_RC="$HOME/.bashrc"
    fi

    if ! grep -q "# Ollama convenience aliases" "$SHELL_RC"; then
        echo -e "\n# Ollama convenience aliases" >> "$SHELL_RC"
        echo "alias ollama-start='$HOME/ollama-scripts/start-ollama-suite.sh'" >> "$SHELL_RC"
        echo "alias ollama-stop='$HOME/ollama-scripts/stop-ollama-suite.sh'" >> "$SHELL_RC"
        echo "alias ollama-status='$HOME/ollama-scripts/status-ollama-suite.sh'" >> "$SHELL_RC"
        echo "alias ollama-backup='$HOME/ollama-scripts/backup-ollama.sh'" >> "$SHELL_RC"
        echo "alias ollama-models='$HOME/ollama-scripts/manage-models.sh'" >> "$SHELL_RC"
        echo "alias ollama-webui='open http://localhost:3000'" >> "$SHELL_RC"
        echo -e "${GREEN}✓ Shell aliases added. Run: source $SHELL_RC${NC}"
    else
        echo -e "${GREEN}✓ Shell aliases already exist.${NC}"
    fi

    chmod +x "$HOME/ollama-scripts/"*.sh
}

# === Main Execution ===

show_banner
check_apple_silicon
check_system_requirements
install_homebrew
install_dependencies
install_ollama
install_openwebui
create_convenience_scripts

echo -e "${GREEN}✓ Installation complete. Use 'ollama-start' to begin, 'ollama-models' to manage models.${NC}"

read -p $'\nWould you like to install a model now? (y/n) ' -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    "$HOME/ollama-scripts/manage-models.sh"
fi
