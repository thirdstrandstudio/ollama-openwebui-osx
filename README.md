```
  _______ _     _         _    ___ _                  _ 
 |__   __| |   (_)       | |  / __| |                | |
    | |  | |__  _ _ __ __| | / /_ | |_ _ __ __ _ _ __ __| 
    | |  | '_ \| | '__/ _` | \ \| | __| '__/ _` | '_ \ / _` |
    | |  | | | | | | | (_| | _\ \ | |_| | | (_| | | | | (_| |
    |_|  |_| |_|_|_|  \__,_| \__/_|\__|_|  \__,_|_| |_|\__,_|
    
    _____ _             _ _       
   / ____| |           | (_)      
  | (___ | |_ _   _  __| |_  ___  
   \___ \| __| | | |/ _` | |/ _ \ 
   ____) | |_| |_| | (_| | | (_) |
  |_____/ \__|\__,_|\__,_|_|\___/ 
```

> **🚀 Crafted with care by [Third Strand Studio](https://thirdstrandstudio.com/)** - *Where code meets creativity*


# Ollama + Open WebUI Installation for macOS Sequoia 15.4.1

This repository contains scripts to automate the installation of Ollama and Open WebUI on macOS Sequoia 15.4.1, optimized for Apple Silicon (M-series) processors.

## 🚀 Quick Installation

To install **Ollama + Open WebUI**, run the following in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/thirdstrandstudio/ollama-openwebui-osx/main/install_wrapper.sh -o install_wrapper.sh;
chmod +x install_wrapper.sh;
./install_wrapper.sh
````

This will:

* Verify your system (Apple Silicon, macOS 15.4.1)
* Install Homebrew if needed
* Install Docker, Node.js, Python 3.11
* Install or update Ollama and Open WebUI
* Add CLI aliases: `ollama-start`, `ollama-stop`, `ollama-status`, `ollama-models`, etc.

Or, you can download this repository, navigate to its directory, and run:

```bash
chmod +x install_ollama.sh
./install_ollama.sh
```

## ✨ Features

- **Automatic Installation**: Installs Ollama and Open WebUI with optimal configurations
- **Apple Silicon Optimized**: Special configurations for M-series processors
- **Model Management**: Easy interface to download, update, and remove models
- **Convenient Scripts**: Start, stop, and check status with simple commands
- **Backup & Restore**: Built-in backup functionality with easy restore process
- **Shell Aliases**: Quick access to common functions through shell aliases

## 🧩 Available Models

The installer includes a model management tool with access to popular models:

- **Mistral Family**: mistral, mistral-openorca, mistral-instruct
- **Llama 3 Family**: llama3, llama3:8b-instruct, llama3:70b
- **Code Models**: codellama:7b, codellama:13b, codellama:34b
- **Multimodal Models**: llava, bakllava
- **Specialized Models**: neural-chat, orca-mini, phi, stablelm-zephyr, gemma:2b, gemma:7b

And support for custom model installation from Ollama's library.

## 🛠️ System Requirements

- macOS Sequoia (15.4.1) or later
- Apple Silicon (M-series) processor (M1/M2/M3/M4)
- At least 8GB RAM (16GB+ recommended)
- At least 20GB free disk space (more for multiple models)
- Internet connection

## 📚 Usage Guide

After installation, you can use the following commands:

### Using Shell Aliases

Once the installation is complete and you've sourced your shell configuration:

```bash
ollama-start      # Start Ollama and Open WebUI
ollama-stop       # Stop Ollama and Open WebUI
ollama-status     # Check status of Ollama and Open WebUI
ollama-models     # Manage models (download, remove, update)
ollama-backup     # Create a backup of Ollama and Open WebUI data
ollama-webui      # Open the web interface in your default browser
```

### Using Scripts Directly

If you prefer not to use aliases, you can use the scripts directly:

```bash
~/ollama-scripts/start-ollama-suite.sh
~/ollama-scripts/stop-ollama-suite.sh
~/ollama-scripts/status-ollama-suite.sh
~/ollama-scripts/manage-models.sh
~/ollama-scripts/backup-ollama.sh
```

## 🌐 Accessing the Web Interface

After starting the Ollama suite, access the Open WebUI at:

```
http://localhost:3000
```

## 💾 Backup and Restore

### Creating a Backup

Run the backup script:

```bash
ollama-backup
```

This creates a timestamped backup folder in your home directory.

### Restoring from Backup

To restore from a backup:

1. Navigate to the backup folder:
   ```bash
   cd ~/ollama_backup_TIMESTAMP
   ```

2. Run the restore script:
   ```bash
   ./restore.sh
   ```

## 🔧 Troubleshooting

If you encounter issues:

1. Check system status:
   ```bash
   ollama-status
   ```

2. Restart the services:
   ```bash
   ollama-stop
   ollama-start
   ```

3. Check Docker is running if Open WebUI doesn't start

4. For model issues, try removing and reinstalling:
   ```bash
   ollama-models
   ```

## 📝 License

This script is provided under the MIT License. Feel free to modify and distribute as needed.

## 🙏 Acknowledgements

- [Ollama Project](https://ollama.com)  
- [Open WebUI Project](https://github.com/open-webui/open-webui)

---

*Note: This installer is not officially affiliated with Ollama or Open WebUI projects.*




