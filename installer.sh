#!/bin/bash

# A script to install the selected dotfiles configuration.

# --- Colors for formatting ---
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_YELLOW="\033[1;33m"
COLOR_RED="\033[1;31m"
COLOR_RESET="\033[0m"

# --- Main Function ---
main() {
    clear
    # Welcome banner
    echo -e "${COLOR_BLUE}"
    echo "========================================"
    echo " Welcome to the Dotfiles Installer! "
    echo "========================================"
    echo -e "${COLOR_RESET}"
    echo "This script will help you set up your environment."
    echo

    # --- Dotfile Selection ---
    # In the future, you can add more options here like "Desktop", "Server", etc.
    PS3="Please select which dotfiles configuration to install: "
    options=("Laptop" "Quit")
    
    select opt in "${options[@]}"; do
        case $opt in
            "Laptop")
                # User selected Laptop configuration
                CONFIG_FOLDER="laptop"
                echo -e "\nYou have selected: ${COLOR_GREEN}$opt${COLOR_RESET}"
                break
                ;;
            "Quit")
                # User chose to exit
                echo -e "${COLOR_YELLOW}Installation cancelled.${COLOR_RESET}"
                exit 0
                ;;
            *) 
                # Invalid option
                echo -e "${COLOR_RED}Invalid option $REPLY. Please try again.${COLOR_RESET}"
                ;;
        esac
    done

    # --- Confirmation ---
    echo
    read -p "Are you sure you want to install the '$opt' configuration? This will back up existing files and create new symbolic links. (y/N) " confirm
    
    if [[ "$confirm" =~ ^[yY](es)?$ ]]; then
        # Check if the configuration folder and its installer script exist
        if [ -d "$CONFIG_FOLDER" ] && [ -f "$CONFIG_FOLDER/install.sh" ]; then
            echo -e "\n${COLOR_BLUE}Proceeding with installation...${COLOR_RESET}"
            # Change to the directory and execute the installer script
            cd "$CONFIG_FOLDER" && ./install.sh
        else
            echo -e "\n${COLOR_RED}Error: Could not find '$CONFIG_FOLDER/install.sh'. Cannot proceed.${COLOR_RESET}"
            exit 1
        fi
    else
        echo -e "\n${COLOR_YELLOW}Installation cancelled by user.${COLOR_RESET}"
        exit 0
    fi
}

# --- Run the main function ---
main
