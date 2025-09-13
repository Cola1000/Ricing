#!/bin/bash

# This script installs this folder's dotfiles configuration.
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
        # This is an Arch-based system, check for yay
        if ! command -v yay &> /dev/null; then
            echo -e "${COLOR_RED}Error: 'yay' is not installed.${COLOR_RESET}"
            echo -e "${COLOR_YELLOW}This script requires 'yay' to install AUR packages. Please install it first.${COLOR_RESET}"
            echo -e "${COLOR_YELLOW}You can find instructions here: https://github.com/Jguer/yay${COLOR_RESET}"
            exit 1
        fi
        
        echo "Using 'yay' to install packages one-by-one..."
        
        while IFS= read -r package || [[ -n "$package" ]]; do
            # Skip empty lines in packages.txt
            if [ -z "$package" ]; then continue; fi

            echo -e "\n${COLOR_BLUE}--> Processing: ${COLOR_GREEN}${package}${COLOR_RESET}"
            
            # First attempt: normal, secure installation
            yes | yay -S --needed --noconfirm "$package"
            
            # Check if the last command failed
            if [ $? -ne 0 ]; then
                echo -e "${COLOR_YELLOW}Warning: Normal installation of '$package' failed. This is likely a GPG key issue.${COLOR_RESET}"
                echo -e "${COLOR_YELLOW}--> Retrying installation for '$package' by skipping the GPG check...${COLOR_RESET}"
                
                # Second attempt: skip GPG check as a fallback
                yes | yay -S --needed --noconfirm --nopgpfetch "$package"
                
                if [ $? -ne 0 ]; then
                    echo -e "${COLOR_RED}Error: Failed to install '$package' even after skipping the GPG check.${COLOR_RESET}"
                    echo -e "${COLOR_RED}Please try installing it manually to diagnose the issue.${COLOR_RESET}"
                else
                    echo -e "${COLOR_GREEN}'$package' installed successfully (GPG check was skipped).${COLOR_RESET}"
                fi
            else
                echo -e "${COLOR_GREEN}'$package' installed successfully.${COLOR_RESET}"
            fi
        done < "$PACKAGE_FILE"

    elif command -v apt-get &> /dev/null; then
        # Fallback for Debian/Ubuntu systems
        echo "Using 'apt-get' to install packages."
        # Note: This will fail for AUR packages.
        cat "$PACKAGE_FILE" | xargs sudo apt-get install -y
    else
        echo -e "${COLOR_RED}Error: Unsupported package manager. Please install packages from '$PACKAGE_FILE' manually.${COLOR_RESET}"
        return
    fi
    
    echo -e "${COLOR_GREEN}Dependency installation is now complete.${COLOR_RESET}"
}

# --- Step 2: Backup Existing Configs ---
backup_configs() {
    echo -e "\n${COLOR_BLUE}Step 2: Backing up existing configuration files...${COLOR_RESET}"
    
    mkdir -p "$DEST_DIR"

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
