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

sysinfo_script="/etc/update-motd.d/50-landscape-sysinfo"
updates_script="/etc/update-motd.d/90-updates-available"

# Add a newline for spacing before the system info.
if [ -x "$sysinfo_script" ] || [ -x "$updates_script" ]; then
    printf "\n"
fi

# Run the system info script if it exists and is executable.
if [ -x "$sysinfo_script" ]; then
    "$sysinfo_script"
fi

printf "\n"
print_info "OS:" "$OS_INFO" "$C_CYAN"
print_info "Kernel:" "$KERNEL" "$C_CYAN"
print_info "Uptime:" "$UPTIME"

printf "\n"

# --- Last Login Info ---
if command -v last >/dev/null 2>&1; then
    printf "%bLast Logins:%b\n" "$C_CYAN" "$C_RESET"
    last -n 3 -a | head -n 3
    printf "\n"
fi

if [ -x "$updates_script" ]; then
    # Execute the script and pipe its output to grep to filter for the wanted lines.
    # The '|| true' prevents the script from failing if no updates are found.
    "$updates_script" | grep --color=never -E "updates can be applied|apt list --upgradable" || true
fi