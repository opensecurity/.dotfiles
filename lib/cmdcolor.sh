#
# REGISTRY: lib/cmdcolor.sh
#
# Provides command-not-found handling with colored output and
# optional command validation coloring in the prompt.
#

# ============================================================================
#  Command-Not-Found Handler
# ============================================================================
# Bash calls this function when a command is not found.
# Provides a clear, colored error with suggestions.
command_not_found_handle() {
    local cmd="$1"
    # Red error message with the failed command highlighted.
    printf '\e[38;5;203m%s\e[0m: command not found\n' "$cmd" >&2

    # If the command-not-found package handler exists, call it for
    # install suggestions (apt, dnf, etc.). This is lightweight because
    # it only runs on actual errors, not on every keystroke.
    if [ -x /usr/lib/command-not-found ]; then
        /usr/lib/command-not-found -- "$cmd" 2>/dev/null
    elif [ -x /usr/share/doc/pkgfile/command-not-found.bash ]; then
        /usr/share/doc/pkgfile/command-not-found.bash "$cmd" 2>/dev/null
    fi

    return 127
}


# ============================================================================
#  Prompt Command Validation Coloring
# ============================================================================
# Colors the most recent command in the prompt output line:
#   - Green if the last command succeeded (exit 0)
#   - Dim red/salmon if the last command failed (exit != 0)
#
# This runs ONCE per prompt (via PROMPT_COMMAND), not per-keystroke,
# so it has zero performance impact on typing.
#
# The approach: after each command, we display a small status indicator
# line showing what ran and whether it succeeded, using the prompt itself.
# This is done inside the prompt builder (_private_build_prompt in prompt.sh)
# by coloring the $ symbol -- already implemented.
#
# For a richer experience: color the DISPLAYED previous command in the
# terminal by injecting ANSI codes after execution. This uses the DEBUG
# trap to capture the command, and PROMPT_COMMAND to render it.

_DOTFILES_LAST_CMD=""
_DOTFILES_LAST_STATUS=""

# Capture the command string before it executes.
# The DEBUG trap fires before each simple command.
_dotfiles_capture_cmd() {
    # Skip if this is being called from PROMPT_COMMAND itself.
    # BASH_COMMAND contains the command about to run.
    # We only capture "real" user commands, not internal functions.
    if [[ "${BASH_COMMAND}" != "_private_build_prompt"* ]] \
    && [[ "${BASH_COMMAND}" != "_dotfiles_"* ]] \
    && [[ "${BASH_COMMAND}" != "history -a"* ]]; then
        _DOTFILES_LAST_CMD="${BASH_COMMAND}"
    fi
}

# Print a colored status line showing the previous command result.
_dotfiles_cmd_status() {
    local exit_code="$1"

    # Allow disabling the status indicator if user prefers a quieter terminal
    [ "${DOTFILES_CMD_STATUS:-true}" = "false" ] && return

    # Don't print anything if there's no captured command.
    [ -z "$_DOTFILES_LAST_CMD" ] && return

    local c_reset='\e[0m'
    local c_green='\e[38;5;114m'   # Soft green - easy on eyes
    local c_red='\e[38;5;203m'     # Soft red/salmon - easy on eyes
    local c_dim='\e[2m'            # Dim text

    if [ "$exit_code" -eq 0 ]; then
        printf "${c_dim}${c_green}✓${c_reset} ${c_dim}%s${c_reset}\n" "$_DOTFILES_LAST_CMD"
    else
        printf "${c_dim}${c_red}✗ [%d]${c_reset} ${c_dim}%s${c_reset}\n" "$exit_code" "$_DOTFILES_LAST_CMD"
    fi

    _DOTFILES_LAST_CMD=""
}

# Install the DEBUG trap for command capture.
# Only set if not already set (avoid stacking on re-source).
if [[ "$(trap -p DEBUG)" != *"_dotfiles_capture_cmd"* ]]; then
    trap '_dotfiles_capture_cmd' DEBUG
fi
