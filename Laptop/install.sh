#!/bin/bash

# This script installs the 'laptop' dotfiles configuration.
# It handles package dependencies, backs up existing configs, and symlinks the new ones.

# --- Configuration ---
# The source directory is the current directory where the script is located.
SOURCE_DIR="$(pwd)"
# The destination for the config files.
DEST_DIR="$HOME/.config"
# File containing the list of packages to install.
PACKAGE_FILE="packages.txt"

# --- Colors ---
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_YELLOW="\033[1;33m"
COLOR_RED="\033[1;31m"
COLOR_RESET="\033[0m"

# --- Helper Functions ---

# Function to print a progress bar
# Usage: progress_bar <current_step> <total_steps>
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed_width=$((width * percentage / 100))
    local remaining_width=$((width - completed_width))

    printf "\r[%.${completed_width}s%.${remaining_width}s] %d%%" "==================================================" "--------------------------------------------------" "$percentage"
}

# --- Step 1: Install Dependencies ---
install_dependencies() {
    echo -e "\n${COLOR_BLUE}Step 1: Installing dependencies...${COLOR_RESET}"
    
    if [ ! -f "$PACKAGE_FILE" ]; then
        echo -e "${COLOR_YELLOW}Warning: '$PACKAGE_FILE' not found. Skipping dependency installation.${COLOR_RESET}"
        return
    fi

    # Detect package manager
    if command -v pacman &> /dev/null; then
        PACKAGE_MANAGER="pacman"
    elif command -v apt-get &> /dev/null; then
        PACKAGE_MANAGER="apt-get"
    else
        echo -e "${COLOR_RED}Error: Unsupported package manager. Please install packages from '$PACKAGE_FILE' manually.${COLOR_RESET}"
        return
    fi
    
    echo "Using '$PACKAGE_MANAGER' to install packages."
    
    # Read packages from file and install them
    while IFS= read -r package || [[ -n "$package" ]]; do
        if [ -n "$package" ]; then
            echo -e "  -> Installing ${COLOR_GREEN}${package}${COLOR_RESET}..."
            if [ "$PACKAGE_MANAGER" == "pacman" ]; then
                sudo pacman -S --noconfirm --needed "$package"
            elif [ "$PACKAGE_MANAGER" == "apt-get" ]; then
                sudo apt-get install -y "$package"
            fi
        fi
    done < "$PACKAGE_FILE"
    
    echo -e "${COLOR_GREEN}Dependency installation complete.${COLOR_RESET}"
}

# --- Step 2: Backup Existing Configs ---
backup_configs() {
    echo -e "\n${COLOR_BLUE}Step 2: Backing up existing configuration files...${COLOR_RESET}"
    
    # Create the config directory if it doesn't exist
    mkdir -p "$DEST_DIR"

    # Get a list of all items (files and dirs) to be symlinked
    local items_to_link=()
    for item in "$SOURCE_DIR"/*; do
        base_item=$(basename "$item")
        # Exclude this script and the package file from being linked
        if [ "$base_item" != "install.sh" ] && [ "$base_item" != "$PACKAGE_FILE" ]; then
            items_to_link+=("$base_item")
        fi
    done

    local total_items=${#items_to_link[@]}
    local current_item=0

    for item_name in "${items_to_link[@]}"; do
        current_item=$((current_item + 1))
        dest_path="$DEST_DIR/$item_name"
        
        if [ -e "$dest_path" ] || [ -L "$dest_path" ]; then
            echo -e "\n  -> Backing up existing '${item_name}' to '${item_name}.backup'"
            mv "$dest_path" "${dest_path}.backup"
        fi
        progress_bar $current_item $total_items
    done
    
    echo -e "\n${COLOR_GREEN}Backup process complete.${COLOR_RESET}"
}


# --- Step 3: Symlink New Dotfiles ---
symlink_dotfiles() {
    echo -e "\n${COLOR_BLUE}Step 3: Creating symbolic links for new dotfiles...${COLOR_RESET}"
    
    local items_to_link=()
    for item in "$SOURCE_DIR"/*; do
        base_item=$(basename "$item")
        if [ "$base_item" != "install.sh" ] && [ "$base_item" != "$PACKAGE_FILE" ]; then
            items_to_link+=("$base_item")
        fi
    done

    local total_items=${#items_to_link[@]}
    local current_item=0

    for item_name in "${items_to_link[@]}"; do
        current_item=$((current_item + 1))
        source_path="$SOURCE_DIR/$item_name"
        dest_path="$DEST_DIR/$item_name"
        
        echo -e "\n  -> Linking '$item_name' to '$DEST_DIR'"
        # Use -T to treat the destination as a normal file/dir, which is safer
        ln -s -T "$source_path" "$dest_path"
        progress_bar $current_item $total_items
    done
    
    echo -e "\n${COLOR_GREEN}Symbolic linking complete.${COLOR_RESET}"
}

# --- Main Execution ---
main() {
    install_dependencies
    backup_configs
    symlink_dotfiles
    
    echo -e "\n${COLOR_GREEN}==========================================="
    echo " Dotfiles installation finished successfully! "
    echo "===========================================${COLOR_RESET}"
    echo "Please restart your terminal or shell to see the changes."
}

main
