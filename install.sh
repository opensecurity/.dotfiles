#!/usr/bin/env bash
#
# REGISTRY: install.sh
#
# Dotfiles Installer
# This script is idempotent and transaction-safe.
#
set -o errexit
set -o nounset
set -o pipefail

#
# CONSTANTS
#
readonly C_DOTFILES_DIR="$HOME/.dotfiles"
readonly C_BACKUP_DIR="$HOME/.dotfiles_backup"
readonly C_TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
readonly C_DOTFILES_TO_LINK=( "bash_profile" "bashrc" )

#
# PRIVATE_HELPERS
#
_log_info() {
    echo "[INFO] $1"
}

_log_error() {
    echo "[ERROR] $1" >&2
}

_check_dependencies() {
    local has_error=0
    local dependencies=( "git" "tput" "dircolors" )
    _log_info "Checking for required dependencies..."
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            _log_error "Required command not found: '$cmd'"
            has_error=1
        fi
    done
    if [ "$has_error" -eq 1 ]; then
        exit 1
    fi
}

#
# IMPLEMENTATION
#
main() {
    _log_info "Starting Dotfiles installation..."

    # Guard Clause: Ensure script is run from the .dotfiles directory.
    if [ "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" != "$C_DOTFILES_DIR" ]; then
        _log_error "This script must be run from within the '$C_DOTFILES_DIR' directory."
        _log_error "Current location: $(pwd)"
        _log_info "Please clone the repository to ~/.dotfiles and run from there."
        exit 1
    fi

    _check_dependencies

    # --- Create .hushlogin file to suppress system MOTD ---
    touch "$HOME/.hushlogin"
    _log_info "Created ~/.hushlogin to suppress default system MOTD."


    # Create backup directory if it doesn't exist.
    mkdir -p "$C_BACKUP_DIR"
    _log_info "Backup directory ensured at: $C_BACKUP_DIR"

    for dotfile in "${C_DOTFILES_TO_LINK[@]}"; do
        local target_link="$HOME/.$dotfile"
        local source_file="$C_DOTFILES_DIR/root/$dotfile"

        # Backup existing file only if it's a regular file and not a symlink.
        if [ -f "$target_link" ] && [ ! -L "$target_link" ]; then
            local backup_file="$C_BACKUP_DIR/.$dotfile.backup.$C_TIMESTAMP"
            _log_info "Backing up existing '$target_link' to '$backup_file'..."
            mv "$target_link" "$backup_file"
        else
            if [ ! -e "$target_link" ]; then
                _log_info "No existing '$target_link' found. Skipping backup."
            else
                _log_info "'$target_link' is already a symlink. Skipping backup."
            fi
        fi

        # Remove existing symlink if it points elsewhere.
        if [ -L "$target_link" ] && [ "$(readlink "$target_link")" != "$source_file" ]; then
            _log_info "Removing old, incorrect symlink at '$target_link'..."
            rm "$target_link"
        fi

        # Create the new symlink.
        if [ ! -L "$target_link" ]; then
            _log_info "Creating symlink: '$target_link' -> '$source_file'"
            ln -s "$source_file" "$target_link"
        else
            _log_info "Symlink for '$dotfile' already correct. No action needed."
        fi
    done

    _log_info "Dotfiles installation complete."
    _log_info "Please restart your shell or run 'source ~/.bash_profile' to apply changes."
}

main "$@"
