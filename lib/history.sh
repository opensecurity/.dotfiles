#
# REGISTRY: lib/history.sh
#
# Shell History Management:
#   - Full substring history search (native GNU Readline)
#   - Multi-word command search (hs)
#   - Real-time multi-session history synchronization
#   - Smart directory navigation (bd)
#

# ============================================================================
#  History Environment Variables
# ============================================================================

# Expand history size for long-term command retention
export HISTSIZE=100000
export HISTFILESIZE=200000

# Ignore duplicate commands and commands starting with a space
export HISTCONTROL="ignoreboth:erasedups"

# Commands to exclude from history
export HISTIGNORE="&:[ ]*:exit:bg:fg:history:clear:cls:c:h:hg:hs:hsync"

# Include full ISO timestamps in history
export HISTTIMEFORMAT="%F %T  "


# ============================================================================
#  Bash History Options (shopt)
# ============================================================================

# Append to history file instead of overwriting on shell exit
shopt -s histappend

# Save multi-line commands as a single history entry
shopt -s cmdhist

# Re-edit a failed history substitution (!$)
shopt -s histreedit

# Verify history substitution before executing
shopt -s histverify


# ============================================================================
#  History Sync Across Multi-Terminal Sessions
# ============================================================================

# Append new entries to the history file immediately after each command.
_dotfiles_history_sync() {
    history -a
}

# Chain into PROMPT_COMMAND without overwriting existing entries.
if [[ "${PROMPT_COMMAND:-}" != *"_dotfiles_history_sync"* ]]; then
    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_dotfiles_history_sync"
fi

# Manual full two-way synchronization: flushes current buffer and re-reads
# entries appended by all other active sessions without restarting the shell.
hsync() {
    history -a
    history -c
    history -r
    printf '\e[32m✓\e[0m History synchronized across all sessions.\n'
}

# Display top most frequently used commands from your history.
hstats() {
    history | awk '{
        for (i=1; i<=NF; i++) {
            if ($i ~ /^[a-zA-Z0-9_\.\/-]+$/ && $i !~ /^[0-9]+$/ && $i !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ && $i !~ /^[0-9]{2}:[0-9]{2}:[0-9]{2}$/) {
                print $i;
                break;
            }
        }
    }' | sort | uniq -c | sort -rn | head -n "${1:-10}"
}


# ============================================================================
#  Native Readline Substring History Search (Zero-Blink, In-Memory)
# ============================================================================
# Binds arrow keys directly to GNU Readline's native C substring search engine.
# Runs directly inside Readline in 0ms without clearing the line or redrawing
# the prompt, completely eliminating any visual flicker or micro-blink.
if [[ $- == *i* ]]; then
    bind '"\e[A": history-substring-search-backward' 2>/dev/null
    bind '"\eOA": history-substring-search-backward' 2>/dev/null
    bind '"\e[B": history-substring-search-forward' 2>/dev/null
    bind '"\eOB": history-substring-search-forward' 2>/dev/null
    bind '"\C-p": history-substring-search-backward' 2>/dev/null
    bind '"\C-n": history-substring-search-forward' 2>/dev/null
    bind '"\e[5~": history-substring-search-backward' 2>/dev/null
    bind '"\e[6~": history-substring-search-forward' 2>/dev/null
    bind '"\e[1;5A": history-substring-search-backward' 2>/dev/null
    bind '"\e[1;5B": history-substring-search-forward' 2>/dev/null
fi


# ============================================================================
#  Multi-Word History Search (hs)
# ============================================================================
# Searches shell history for commands matching ALL provided keywords in any order.
# Highlights matching terms in color and displays command index & timestamp.
#
# Usage:
#   hs                      # Show last 30 commands
#   hs docker               # Show commands containing "docker"
#   hs docker run           # Show commands containing BOTH "docker" AND "run"
#   hs -n 50 git commit     # Show up to 50 matching commands
#
hs() {
    local limit=40
    local terms=()

    while [ $# -gt 0 ]; do
        case "$1" in
            -n)
                limit="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: hs [-n count] [keyword1] [keyword2] ..."
                echo ""
                echo "Searches command history for entries matching ALL keywords in any order."
                echo "Highlights matched words and displays command ID and timestamps."
                echo ""
                echo "Options:"
                echo "  -n <count>    Limit output to the last <count> matches (default: 40)"
                echo "  -h, --help    Show this help message"
                echo ""
                echo "Examples:"
                echo "  hs docker run"
                echo "  hs git commit typo"
                echo "  hs -n 20 kubectl logs"
                return 0
                ;;
            *)
                terms+=("$1")
                shift
                ;;
        esac
    done

    if [ ${#terms[@]} -eq 0 ]; then
        history | tail -n "$limit"
        return 0
    fi

    # Pipe through grep for each term to perform a logical AND
    local cmd="history"
    for term in "${terms[@]}"; do
        cmd+=" | grep -i --color=always -F -- $(printf '%q' "$term")"
    done
    cmd+=" | tail -n $limit"

    eval "$cmd"
}


# ============================================================================
#  Smart Directory Navigation (bd)
# ============================================================================

# bd (back directory): Jump quickly to any parent directory by name.
# Example: from /usr/local/share/doc/example, run "bd share" -> jumps to /usr/local/share
bd() {
    if [ $# -eq 0 ]; then
        cd .. && return
    fi
    local target="$1"
    local pwd_str="$PWD"
    local dest="${pwd_str%/$target/*}/$target"
    if [ "$dest" = "$pwd_str" ]; then
        dest="${pwd_str%/$target}/$target"
    fi
    if [ -d "$dest" ] && [ "$dest" != "$pwd_str" ]; then
        cd "$dest" || return
    else
        echo "bd: No parent directory matching '$target' found" >&2
        return 1
    fi
}
