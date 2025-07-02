#!/usr/bin/env bash
#
# REGISTRY: uninstall.sh
#
# Dotfiles Uninstaller
# Restores backups and cleans up symlinks.
#
set -o errexit
set -o nounset
set -o pipefail

#
# CONSTANTS
#
readonly C_DOTFILES_DIR="$HOME/.dotfiles"
readonly C_BACKUP_DIR="$HOME/.dotfiles_backup"
readonly C_DOTFILES_TO_UNLINK=( "bash_profile" "bashrc" )

#
# PRIVATE_HELPERS
#
_log_info() {
    echo "[INFO] $1"
}

_log_warn() {
    echo "[WARN] $1" >&2
}

_log_error() {
    echo "[ERROR] $1" >&2
}

#
# IMPLEMENTATION
#
main() {
    _log_info "Starting Dotfiles uninstallation..."

    for dotfile in "${C_DOTFILES_TO_UNLINK[@]}"; do
        local target_link="$HOME/.$dotfile"
        local source_file="$C_DOTFILES_DIR/root/$dotfile"

        # Remove the symlink if it points to our dotfiles repo.
        if [ -L "$target_link" ] && [ "$(readlink "$target_link")" == "$source_file" ]; then
            _log_info "Removing symlink '$target_link'..."
            rm "$target_link"
        else
            _log_warn "Symlink for '$dotfile' does not exist or points elsewhere. Skipping."
        fi

        # Restore the latest backup if one exists.
        if [ -d "$C_BACKUP_DIR" ]; then
            local latest_backup
            latest_backup=$(find "$C_BACKUP_DIR" -name ".$dotfile.backup.*" -print0 | xargs -0 ls -t | head -n 1)

            if [ -f "$latest_backup" ]; then
                _log_info "Restoring backup for '$dotfile' from '$latest_backup'..."
                cp "$latest_backup" "$target_link"
            else
                _log_warn "No backup found for '$dotfile' in '$C_BACKUP_DIR'. Cannot restore."
            fi
        fi
    done

    _log_info "Dotfiles uninstallation complete."
    _log_info "The repository at '$C_DOTFILES_DIR' and backups at '$C_BACKUP_DIR' have NOT been removed."
    _log_info "You may remove them manually if you wish."
    _log_info "Please restart your shell to apply changes."
}

main "$@"
