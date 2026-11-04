#
# REGISTRY: lib/init.sh
#
# Initializer
#

#
# CONSTANTS
#
C_DOTFILES_LIB_DIR="${BASH_SOURCE[0]%/*}"

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
_safe_source "${C_DOTFILES_LIB_DIR}/history.sh" "History"
_safe_source "${C_DOTFILES_LIB_DIR}/aliases.sh" "Aliases"
_safe_source "${C_DOTFILES_LIB_DIR}/functions.sh" "Functions"
_safe_source "${C_DOTFILES_LIB_DIR}/prompt.sh" "Prompt"
_safe_source "${C_DOTFILES_LIB_DIR}/cmdcolor.sh" "CmdColor"

# Source bash completion if available (provides completions for git, docker, etc.).
if [ -f /usr/share/bash-completion/bash_completion ]; then
    # shellcheck source=/dev/null
    source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    # shellcheck source=/dev/null
    source /etc/bash_completion
elif [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
    # shellcheck source=/dev/null
    source /opt/homebrew/etc/profile.d/bash_completion.sh
elif [ -f /usr/local/etc/bash_completion ]; then
    # shellcheck source=/dev/null
    source /usr/local/etc/bash_completion
fi

# SSH host completion from ~/.ssh/config and ~/.ssh/known_hosts (zero dependencies)
_dotfiles_ssh_hosts() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local hosts=""
    if [ -f "$HOME/.ssh/config" ]; then
        hosts+=$(awk '/^Host [^*]/ {for (i=2; i<=NF; i++) print $i}' "$HOME/.ssh/config" 2>/dev/null)
    fi
    if [ -f "$HOME/.ssh/known_hosts" ]; then
        hosts+=" $(awk -F'[, ]' '{print $1}' "$HOME/.ssh/known_hosts" 2>/dev/null | grep -v '^[\[|#]') "
    fi
    COMPREPLY=( $(compgen -W "$hosts" -- "$cur") )
}
complete -F _dotfiles_ssh_hosts ssh scp sftp 2>/dev/null

# Wire git branch completion to short git aliases if git completion is loaded
if declare -F __git_complete >/dev/null 2>&1; then
    __git_complete gco _git_checkout
    __git_complete gp _git_push
    __git_complete gpl _git_pull
    __git_complete gb _git_branch
    __git_complete gd _git_diff
fi

# Load user-specific local overrides if present (not tracked in version control)
if [ -f "$HOME/.bashrc.local" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.bashrc.local"
fi

#
# PRIVATE_HELPERS
#
unset -f _safe_source
