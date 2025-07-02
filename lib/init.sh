#
# REGISTRY: lib/init.sh
#
# Initializer
#

#
# CONSTANTS
#
readonly C_DOTFILES_LIB_DIR="${BASH_SOURCE[0]%/*}"

#
# IMPLEMENTATION
#

# --- Display Personal MOTD on initial SSH Login ---
if [ -n "$SSH_CONNECTION" ] && [ "${SHLVL:-1}" -eq 1 ]; then
    bash "${C_DOTFILES_LIB_DIR}/motd.sh"
fi


# Define a robust sourcing function.
_safe_source() {
    local component_path="$1"
    local component_name="$2"
    if [ -f "$component_path" ]; then
        # shellcheck source=/dev/null
        source "$component_path"
    fi
}

# Source the core components.
_safe_source "${C_DOTFILES_LIB_DIR}/exports.sh" "Exports"
_safe_source "${C_DOTFILES_LIB_DIR}/aliases.sh" "Aliases"
_safe_source "${C_DOTFILES_LIB_DIR}/functions.sh" "Functions"
_safe_source "${C_DOTFILES_LIB_DIR}/prompt.sh" "Prompt"

#
# PRIVATE_HELPERS
#
unset -f _safe_source
