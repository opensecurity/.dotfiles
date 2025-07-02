#!/bin/bash
#
# REGISTRY: motd.sh
#
# A dynamic MOTD script that provides a personal system overview on login.
#
set -o errexit
set -o nounset
set -o pipefail

# --- Color Definitions ---
readonly C_RESET='\e[0m'
readonly C_CYAN='\e[0;36m'
readonly C_BOLD_CYAN='\e[1;36m'
readonly C_GREEN='\e[0;32m'
readonly C_YELLOW='\e[0;33m'
readonly C_RED='\e[0;31m'

# --- Helper for two-column printing ---
print_info() {
    printf "  %-18s %b%s%b\n" "$1" "${3:-$C_YELLOW}" "$2" "$C_RESET"
}

# --- Data Gathering ---
readonly HOSTNAME=$(hostname)
readonly OS_INFO=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f 2)
readonly KERNEL=$(uname -r)
readonly UPTIME=$(uptime -p | sed 's/up //')


# --- ASCII Art Header ---
header_line=$(printf "%0.s-" {1..50})
box_width=50
padding=$((($box_width - ${#HOSTNAME} - 2) / 2))

# --- Display Output ---
printf "\n"
printf "%b%s%b\n" "$C_BOLD_CYAN" "$header_line" "$C_RESET"
printf "%b|%*s%s%*s|%b\n" "$C_BOLD_CYAN" "$padding" "" "$HOSTNAME" "$((box_width - padding - ${#HOSTNAME} - 2))" "" "$C_RESET"
printf "%b%s%b\n" "$C_BOLD_CYAN" "$header_line" "$C_RESET"

printf "\n"
print_info "OS:" "$OS_INFO" "$C_CYAN"
print_info "Kernel:" "$KERNEL" "$C_CYAN"
print_info "Uptime:" "$UPTIME"

# --- System Updates (Ubuntu/Debian) ---
# This file is managed by the 'update-notifier-common' package.
updates_file="/var/lib/update-notifier/updates-available"
if [ -r "$updates_file" ]; then # If the file is readable
    # Read the number of total and security updates from the file.
    # The '|| true' prevents the script from exiting if grep finds no matches.
    num_packages=$(grep -c "packages can be updated." "$updates_file" || true)
    num_security=$(grep -c "security updates" "$updates_file" || true)

    if [ "$num_packages" -gt 0 ]; then
        message="$num_packages packages"
        if [ "$num_security" -gt 0 ]; then
            # Color security updates red to highlight importance
            message+=" (${C_RED}${num_security} security${C_YELLOW})"
        fi
        print_info "System Updates:" "$message" "$C_YELLOW"
    fi
fi

printf "\n"

# --- Last Login Info ---
if command -v last >/dev/null 2>&1; then
    printf "%bLast Logins:%b\n" "$C_CYAN" "$C_RESET"
    last -n 3 -a | head -n 3
    printf "\n"
fi
