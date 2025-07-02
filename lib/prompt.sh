#
# REGISTRY: lib/prompt.sh
#
# Defines a unique, colorized, git-aware shell prompt (PS1)
# with privacy-focused truncation and individually-colored git-status indicators.
#

#
# TYPE_DEFINITIONS
#
# Truncates the username to the first and last letter, separated by asterisks.
_private_truncate_user() {
    local user_string="$USER"
    # If username is 2 chars or less, show it fully.
    if [ "${#user_string}" -le 2 ]; then
        echo "$user_string"
        return
    fi
    local first_letter="${user_string:0:1}"
    local last_letter="${user_string: -1}"
    echo "${first_letter}**${last_letter}"
}

# Truncates the hostname to the first 3 and last letter, separated by asterisks.
_private_truncate_host() {
    local host_string
    host_string=$(hostname -s) # Use command for reliability.
    # If hostname is 4 chars or less, show it fully.
    if [ "${#host_string}" -le 4 ]; then
        echo "$host_string"
        return
    fi
    local first_three="${host_string:0:3}"
    local last_letter="${host_string: -1}"
    echo "${first_three}**${last_letter}"
}


# Gets a comprehensive, individually-colorized git status.
_private_prompt_git_info() {
    # Guard Clause: Must be inside a git work tree.
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        return 1
    fi

    # Define colors here, wrapped for PS1 compatibility
    local c_reset='\[\e[0m\]'
    local c_bold_red='\[\e[1;31m\]'
    local c_red='\[\e[31m\]'
    local c_green='\[\e[32m\]'
    local c_yellow='\[\e[33m\]'
    local c_cyan='\[\e[36m\]'
    local c_magenta='\[\e[35m\]'

    local branch_name
    branch_name=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo '(unknown)')

    # --- File Status (Individually Colored) ---
    local file_status=''
    if ! git diff --quiet --ignore-submodules --cached; then file_status+="${c_green}+${c_reset}"; fi
    if ! git diff-files --quiet --ignore-submodules --; then file_status+="${c_yellow}*${c_reset}"; fi
    if [ -n "$(git ls-files --others --exclude-standard)" ]; then file_status+="${c_red}?${c_reset}"; fi

    # --- Stash Status ---
    local stash_status=''
    if [ -n "$(git stash list -q | head -n 1)" ]; then
        stash_status="${c_magenta}\$${c_reset}"
    fi

    # --- Branch Status vs. Remote ---
    local remote_status=''
    if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
        local remote_counts
        remote_counts=$(git rev-list --left-right --count @{u}...HEAD)
        local behind ahead
        behind=$(echo "$remote_counts" | awk '{print $1}')
        ahead=$(echo "$remote_counts" | awk '{print $2}')

        if [ "$behind" -gt 0 ] && [ "$ahead" -gt 0 ]; then
            remote_status="${c_bold_red}<>${c_reset}"
        elif [ "$behind" -gt 0 ]; then
            remote_status="${c_red}<${c_reset}"
        elif [ "$ahead" -gt 0 ]; then
            remote_status="${c_green}>${c_reset}"
        fi
    fi
    
    local final_status="${remote_status}${stash_status}${file_status}"

    if [ -n "$final_status" ]; then
        echo " on ${c_cyan}${branch_name}${c_reset} ${final_status}"
    else
        echo " on ${c_cyan}${branch_name}${c_reset}"
    fi
}

#
# IMPLEMENTATION
#
# Builds and exports the primary shell prompt (PS1).
#
_private_build_prompt() {
    local last_exit_code="$?"
    local prompt_symbol

    # ANSI color escape sequences.
    local c_reset='\[\e[0m\]'
    local c_bold='\[\e[1m\]'
    local c_blue='\[\e[34m\]'
    local c_cyan='\[\e[36m\]'
    local c_red='\[\e[31m\]'
    local c_green='\[\e[32m\]' # For host color

    # Determine user color
    local user_color
    if [ "$EUID" -eq 0 ]; then user_color="${c_red}"; else user_color="${c_blue}"; fi
    # Determine host color
    local host_color
    if [ -n "$SSH_TTY" ]; then host_color="${c_bold}${c_cyan}"; else host_color="${c_green}"; fi

    # Determine prompt symbol color based on last exit code
    if [ "$last_exit_code" -eq 0 ]; then prompt_symbol="\$"; else prompt_symbol="${c_red}\$${c_reset}"; fi

    # Get truncated and git info
    local truncated_user=$(_private_truncate_user)
    local truncated_host=$(_private_truncate_host)
    local git_info=$(_private_prompt_git_info)

    # Set terminal title to the current folder name.
    PS1="\[\033]0;\W\007\]"

    # Build the prompt line
    PS1+="${user_color}${truncated_user}${c_reset}@${host_color}${truncated_host}${c_reset}"
    PS1+=":${c_blue}\W${c_reset}" # Current folder name
    # git_info now contains its own colors, so we don't add any here.
    if [ -n "$git_info" ]; then
        PS1+="${git_info}"
    fi
    PS1+=" ${prompt_symbol} "

    export PS1
}

PROMPT_COMMAND="_private_build_prompt"
