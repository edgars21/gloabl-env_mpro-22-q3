#!/bin/bash

SCRIPT_ROOT=$(echo $(cd $(dirname "$0") && pwd))

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

check_for_commands() {
    command_exists apt-get || {
        echo "Error: apt-get is not installed"
        exit 1
    }

    command_exists curl || {
        echo "Error: curl is not installed"
        exit 1
    }

    command_exists sh || {
        echo "Error: sh is not installed"
        exit 1
    }             
}

setup_zsh() {
    echo "Setting zsh..."

    echo "Checking: if have zsh"
    if ! command_exists zsh; then
        echo "Installing: zsh"
        sudo -k apt-get install zsh || {
            echo "Error: apt-get zsh failed! Exiting"
            exit 1
        }
    else
        echo "zsh is installed! Skipping"        
    fi

    echo "Checking: if zsh is default shell"
    if [ $(basename $SHELL) = "zsh" ]; then
        echo "zsh is default shell"
    else
        echo "zsh is not default, setting zsh as defualt"
        ZSH=$(command -v zsh)
        sudo -k chsh -s "$ZSH" "$USER"
    fi    
}

setup_ohmyzsh() {
    echo "Setting: oh-my-zsh..."

    echo "Checking: if have oh-my-zsh"
    ZSH_directory="$HOME/.oh-my-zsh"
    if [ -d $ZSH_directory ]; then
        echo "oh-my-zsh is istalled! Skipping"
        return 0
    fi    

    echo "Running: oh-my-zsh installer"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
        echo "Error: oh-my-zsh installer failed! Exiting"
        exit 1
    }
}

setup_powerlevel10k() {
    echo "Setting: powerlevel10k..."

    echo "Checking: if have powerlevel10k"
    powerlevel10k_directory="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [ -d $powerlevel10k_directory ]; then
        echo "oh-my-zsh is istalled! Skipping"
        return 0
    fi     

    echo "Cloning p10k repo"
    if command_exists git; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k ||
        echo "Error: couldn't clone form git"
    else
        echo "Will move from local then"
        mv ${SCRIPT_ROOT}/powerlevel10k ${HOME}/.oh-my-zsh/custom/themes || {
            echo "Error: couldn't copy from local! Exiting"
            exit 1
        }
    fi

    echo "powerlevel10k setup success"
}

setup_global_settings() {
    echo "Setting: global settings..."

    cp "${SCRIPT_ROOT}/config/.zshrc" $HOME &&
    cp "${SCRIPT_ROOT}/config/.zshrc.global" $HOME &&
    touch $HOME/.zshrc.local &&
    cp "${SCRIPT_ROOT}/config/.p10k.zsh" $HOME/ || {
        echo "Error: while copying global settings"
        return 1        
    }

    echo "Moving: oh-my-zsh plugins..."
    cp -r "${SCRIPT_ROOT}/config/oh-my-zsh/plugins/zsh-autosuggestions" "$HOME/.oh-my-zsh/custom/plugins/" &&
    cp -r "${SCRIPT_ROOT}/config/oh-my-zsh/plugins/zsh-syntax-highlighting" "$HOME/.oh-my-zsh/custom/plugins/" || {
        echo "Error: while moving plugins"
        return 1
    }

    echo "global settings setup success"
}

main() {
    check_for_commands
    setup_zsh
    setup_ohmyzsh
    setup_powerlevel10k
    setup_global_settings
}

main "$@"