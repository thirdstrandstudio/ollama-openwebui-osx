#!/bin/bash

# Ollama + Open WebUI Installation Wrapper Script
# For macOS Sequoia 15.4.1 on Apple Silicon

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Ollama + Open WebUI Installer for macOS${NC}"
echo -e "${YELLOW}This script will download and run the installation script.${NC}"
echo

# Check if we're running on macOS
if [[ $(uname) != "Darwin" ]]; then
    echo -e "${RED}Error: This script is designed for macOS only.${NC}"
    exit 1
fi

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
SCRIPT_PATH="$TEMP_DIR/install_ollama.sh"

echo -e "${BLUE}Downloading installation script...${NC}"

curl -fsSL -o "$SCRIPT_PATH" "https://raw.githubusercontent.com/thirdstrandstudio/ollama-openwebui-osx/refs/heads/main/install_ollama.sh"
if [[ ! -s "$SCRIPT_PATH" ]]; then
    echo -e "${RED}Error: Failed to download the installation script.${NC}"
    echo -e "${YELLOW}Instead, you can download the script manually and run it with:${NC}"
    echo -e "bash ~/Downloads/install_ollama.sh"
    exit 1
fi

# Make it executable
chmod +x "$SCRIPT_PATH"

echo -e "${GREEN}Installation script downloaded successfully.${NC}"
echo -e "${YELLOW}Running the installation script interactively...${NC}"
echo

# Run interactively
bash "$SCRIPT_PATH"

# Clean up
echo -e "${BLUE}Cleaning up temporary files...${NC}"
rm -rf "$TEMP_DIR"
