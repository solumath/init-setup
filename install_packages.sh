#!/bin/bash

# packages to install
INSTALL="copyq docker docker-compose ffmpeg filezilla flake8 gimp git gnome-shell-extension-manager gnome-tweaks \
gparted htop libdvd-pkg libdvdnav4 mpv nomacs neofetch python3-pip tmux ubuntu-restricted-extras xsel vlc zsh"

# dictionary of apps to install
declare -A app_urls
app_urls["discord"]="https://discord.com/api/download?platform=linux&format=deb"
app_urls["vscode"]="https://go.microsoft.com/fwlink/?LinkID=760868"
app_urls["bitwarden"]="https://vault.bitwarden.com/download/?app=desktop&platform=linux&variant=deb"
app_urls["realvnc"]="https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-7.6.0-Linux-x64.deb"
app_urls["gitkraken"]="https://release.axocdn.com/linux/gitkraken-amd64.deb"
app_urls["opera"]="https://download3.operacdn.com/ftp/pub/opera/desktop/102.0.4880.16/linux/opera-stable_102.0.4880.16_amd64.deb"

# packages to remove
REMOVE="remmina"

# COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'        # No Color

# variables
success_apps=()
success_packages=()
success_actions=()
fail_apps=()
fail_packages=()
fail_actions=()

# array of actions to perform
actions_array=("copy_dotfiles" "copy_terminal_profile" "load_gnome_settings" "setup_grub_theme")

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with sudo or as root."
    exit 1
fi

# if no arguments are passed, set the argument to "all"
if [ $# -eq 0 ]; then
    set -- "all"
fi

# check if "all" argument is used with other arguments
for arg in "$@"; do
    if [ "$arg" == "all" ] && [[ "$#" -gt 1 ]]; then
        echo "Error: Cannot use 'all' argument with other arguments."
        exit 1
    fi
done

init_apps() {
    # install apps from app_urls
    for app in "${!app_urls[@]}"; do
        url="${app_urls[$app]}"
        echo -e "\nDownloading $app from $url"
        if wget_output=$(wget -O "$app.deb" "$url" 2>&1); then
            echo -e "${GREEN}Download of $app successful${NC}"
            if dpkg_output=$(dpkg -i "$app.deb" 2>&1); then
                echo -e "${GREEN}Installation of $app successful${NC}"
                rm "$app.deb"
                success_apps+=("$app")
            else
                echo -e "${RED}Installation of $app failed\n$dpkg_output${NC}"
                fail_apps+=("$app")
            fi
        else
            echo -e "${RED}Download of $app failed\n$wget_output${NC}"
            fail_apps+=("$app")
        fi
    done
}

init_packages() {
    for package in $INSTALL; do
        echo -e "\nInstalling: $package"
        if install_output=$(apt install -y $package 2>&1); then
            echo -e "${GREEN}Installed: $package${NC}"
            success_packages+=("$package")
        else
            echo -e "${RED}Package $package not found or installation failed\n$install_output${NC}"
            fail_packages+=("$package")
        fi
    done
}

remove_packages() {
    for package in $REMOVE; do
        echo -e "\nRemoving: $package"
        if purge_output=$(apt purge $package 2>&1); then
            echo -e "${GREEN}Removed: $package${NC}"
        else
            echo -e "${RED}Package $package not found or purge failed\$purge_output${NC}"
        fi
    done
}

copy_dotfiles() {
    if load_output=$(cp -a ./dotfiles/. ~/ 2>&1); then
        echo -e "${GREEN}Dotfiles copied successfully${NC}"
        success_actions+=("Copy dotfiles")
    else
        echo -e "${RED}Error copying dotfiles${NC}"
        echo -e "${RED}$load_output${NC}"
        fail_actions+=("Copy dotfiles")
    fi
}

copy_terminal_profile() {
    if load_output=$(dconf load /org/gnome/terminal/legacy/profiles:/ < ./gnome-terminal-profiles.dconf 2>&1); then
        echo -e "${GREEN}Gnome terminal profiles loaded successfully${NC}"
        success_actions+=("Copy terminal profile")
    else
        echo -e "${RED}Error loading gnome terminal profiles${NC}"
        echo -e "${RED}$load_output${NC}"
        fail_actions+=("Copy terminal profile")
    fi
}

load_gnome_settings() {
    if load_output=$(dconf load / < ./saved_settings.dconf 2>&1); then
        echo -e "${GREEN}Settings loaded successfully${NC}"
        success_actions+=("Load gnome settings")
    else
        echo -e "${RED}Error loading settings${NC}"
        echo -e "${RED}$load_output${NC}"
        fail_actions+=("Load gnome settings")
    fi
}

setup_grub_theme() {
    tar -xf vimix.tar.xz
    cd Vimix-1080p
    if theme_install_output=$(./install.sh 2>&1); then
        echo -e "${GREEN}Grub theme installed successfully${NC}"
        success_actions+=("Install grub theme")
    else
        echo -e "${RED}Error installing grub theme${NC}"
        echo -e "${RED}$theme_install_output${NC}"
        fail_actions+=("Install grub theme")
    fi
}

display_results() {
    local -n success=$1
    local -n fails=$2
    local -n name=$3
    success_count=${#success[@]}
    fail_count=${#fails[@]}

    echo -e "\n${GREEN}Successful $name: $success_count${NC}"
    echo -e "${RED}Failed $name: $fail_count${NC}"
    if [ $fail_count -gt 0 ]; then
        echo -e "\nFailed $name:"
        for fail in "${fails[@]}"; do
            echo -e "${RED}\t- $fail${NC}"
        done
    fi
}

for arg in "$@"; do
    case "$arg" in
        "-all")
            echo "Initializing all..."
            apt-get update && apt-get upgrade -y
            init_apps
            init_packages
            for action in "${actions_array[@]}"; do
                $action
            done
            display_results success_apps fail_apps "apps"
            display_results success_packages fail_packages "packages"
            display_results success_actions fail_actions "actions"
            ;;
        "-apps")
            echo "Initializing apps..."
            init_apps
            display_results success_apps fail_apps "apps"

            ;;
        "-packages")
            echo "Initializing packages..."
            init_packages
            display_results success_packages fail_packages "packages"
            ;;
        "-actions")
            echo "Initializing actions..."
            for action in "${actions_array[@]}"; do
                echo "Running $action"
                $action
            done
            display_results success_actions fail_actions "actions"
            ;;
        *)
            echo "Invalid argument: $arg"
            exit 1
            ;;
    esac
done
