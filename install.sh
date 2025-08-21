#!/bin/bash

# Simple dotfiles installer

install_func() {
    # Get the directory where this script is located
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Copy all dotfiles and directories to home directory
    for item in "$DOTFILES_DIR"/.* "$DOTFILES_DIR"/*; do
        # Skip . and .. directories, .git, and the install script itself
        basename_item=$(basename "$item")
        if [[ "$basename_item" == "." || "$basename_item" == ".." || "$basename_item" == ".git" || "$basename_item" == "install.sh" || "$basename_item" == "README.md" ]]; then
            continue
        fi
        
        # Copy to home directory
        if [[ -f "$item" || -d "$item" ]]; then
            cp -r "$item" "$HOME/"
        fi
    done
    
    echo "Dotfiles installation complete!"
}

# main installator
install_func
