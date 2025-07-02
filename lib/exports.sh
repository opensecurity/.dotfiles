#
# REGISTRY: lib/exports.sh
#
# Manages environment variables for the shell session.
#

#
# CONSTANTS
#
readonly C_DEFAULT_EDITOR="nano"
readonly C_DEFAULT_LOCALE="en_US.UTF-8"

#
# IMPLEMENTATION
#
export EDITOR="${EDITOR:-$C_DEFAULT_EDITOR}"
export VISUAL="${VISUAL:-$C_DEFAULT_EDITOR}"

# Set locale only if the `locale` command is available AND the desired locale exists.
# This prevents warnings on systems where 'en_US.UTF-8' is not generated.
if command -v locale >/dev/null 2>&1; then
    # The grep is case-insensitive ('-i') and matches the whole line ('-x')
    # to handle variations like 'utf8' vs 'UTF-8' and prevent partial matches.
    if locale -a | grep -q -i -x "$C_DEFAULT_LOCALE"; then
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
export HISTSIZE=10000
export HISTFILESIZE=20000

# Do not put duplicate lines or lines starting with space in the history.
export HISTIGNORE="&:[ ]*"
