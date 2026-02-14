#
# REGISTRY: lib/exports.sh
#
# Manages environment variables for the shell session.
#

#
# CONSTANTS
#
C_DEFAULT_EDITOR="nano"
C_DEFAULT_LOCALE="en_US.UTF-8"
DOTFILES_OS="$(uname -s)"

#
# IMPLEMENTATION
#
export EDITOR="${EDITOR:-$C_DEFAULT_EDITOR}"
export VISUAL="${VISUAL:-$C_DEFAULT_EDITOR}"

# Set locale only if the `locale` command is available AND the desired locale exists.
# This prevents warnings on systems where 'en_US.UTF-8' is not generated.
if command -v locale >/dev/null 2>&1; then
    # Match both 'en_US.UTF-8' and 'en_US.utf8' formats reported by locale -a.
    if locale -a 2>/dev/null | grep -q -i 'en_US\.utf-\?8'; then
        export LANG="$C_DEFAULT_LOCALE"
        export LC_ALL="$C_DEFAULT_LOCALE"
    fi
fi

export PATH="$PATH:/usr/local/sbin:/usr/local/bin"

# Enable color support for tools that respect this variable.
export CLICOLOR=1
export LSCOLORS="GxFxCxDxBxegedabagaced"

# Configure shell history to ignore duplicate commands.
export HISTCONTROL="ignoredups:erasedups"

# Increase history size.
export HISTSIZE=50000
export HISTFILESIZE=100000

# Do not put duplicate lines or lines starting with space in the history.
export HISTIGNORE="&:[ ]*:exit:bg:fg:history:clear:cls:c"

# Add timestamps to history entries.
export HISTTIMEFORMAT="%F %T  "


# ============================================================================
#  Shell Options (shopt)
# ============================================================================

# Append to history file instead of overwriting (critical for multi-session).
shopt -s histappend

# Save multi-line commands as a single history entry.
shopt -s cmdhist

# Re-edit a failed history substitution.
shopt -s histreedit

# Verify history substitution before executing.
shopt -s histverify

# Auto-correct minor cd typos (e.g., "cd /ect" -> "cd /etc").
shopt -s cdspell

# Correct minor directory name typos during word completion.
shopt -s dirspell 2>/dev/null

# Allow "cd dirname" without typing "cd" (just type the directory name).
shopt -s autocd 2>/dev/null

# Enable recursive globbing with ** (e.g., "ls **/*.py").
shopt -s globstar 2>/dev/null

# Update LINES and COLUMNS after each command (resize handling).
shopt -s checkwinsize

# Allow dotfiles to be matched by glob patterns.
shopt -s dotglob

# Use extended pattern matching (?(pat), *(pat), +(pat), @(pat), !(pat)).
shopt -s extglob

# Case-insensitive glob matching.
shopt -s nocaseglob

# If a glob pattern matches nothing, expand to empty instead of the literal.
shopt -s nullglob 2>/dev/null


# ============================================================================
#  History Sync Across Sessions
# ============================================================================
# Append new entries to the history file after each command.
# We intentionally do NOT use "history -c; history -r" here because that
# resets readline's internal history pointer on every prompt, which breaks
# Up-arrow prefix search for commands typed in the current session.
# New terminals inherit the full history on startup automatically.
_dotfiles_history_sync() {
    history -a
}

# Chain into PROMPT_COMMAND without overwriting existing entries.
if [[ "${PROMPT_COMMAND:-}" != *"_dotfiles_history_sync"* ]]; then
    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_dotfiles_history_sync"
fi
