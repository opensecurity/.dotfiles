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

# Prepend standard user bin directories if they exist (without duplicating).
for _dir in "$HOME/.local/bin" "$HOME/bin" "/usr/local/bin" "/usr/local/sbin"; do
    if [ -d "$_dir" ] && [[ ":$PATH:" != *":$_dir:"* ]]; then
        PATH="$_dir:$PATH"
    fi
done
unset _dir
export PATH

# Default pager with ANSI color and smart-case search support.
export PAGER="${PAGER:-less}"
export LESS="-R -i -M --shift 5"

# Enable color support for tools that respect this variable.
export CLICOLOR=1
export LSCOLORS="GxFxCxDxBxegedabagaced"

# Colored diagnostic output for GCC and Clang builds.
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Clean output formatting for Bash built-in time keyword.
export TIMEFORMAT=$'\nreal\t%3R\nuser\t%3U\nsys\t%3S'

# ============================================================================
#  Shell Options (shopt)
# ============================================================================

# Do not search entire PATH when pressing Tab on an empty line (prevents terminal lag).
shopt -s no_empty_cmd_completion 2>/dev/null

# Automatically expand variables in directory completion (e.g. $HOME/doc<tab>).
shopt -s direxpand 2>/dev/null

# Inherit completion rules for aliases (e.g. g='git' gets git's tab completions).
shopt -s progcomp_alias 2>/dev/null

# Warn before exiting if background jobs are still running.
shopt -s checkjobs 2>/dev/null

# Do not match '.' and '..' when globbing hidden files with .*
shopt -s globskipdots 2>/dev/null

# Properly quote filenames with spaces during tab completion.
shopt -s complete_fullquote 2>/dev/null

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
