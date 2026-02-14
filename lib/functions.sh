#
# REGISTRY: lib/functions.sh
#
# Defines general-purpose and domain-specific shell functions.
#

#
# IMPLEMENTATION
#

# --- General Purpose ---

# Renders a horizontal rule across the terminal width.
function term_rule() {
    local line_char="${1:--}"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' "${line_char}"
}

# Shows system uptime in a human-readable format.
function sys_uptime() {
    if ! command -v uptime >/dev/null 2>&1; then
        echo "Error: 'uptime' command not found." >&2; return 1;
    fi
    uptime -p
}

# Creates a directory and changes into it.
function mkd() {
    if [ -z "$1" ]; then
        echo "Usage: mkd <directory-name>" >&2; return 1;
    fi
    mkdir -p "$1" && cd "$1" || return
}

# Extracts common archive formats automatically.
function extract() {
    if [ -z "$1" ] || [ ! -f "$1" ]; then
        echo "Usage: extract <archive_file>" >&2; return 1;
    fi
    case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz)  tar xzf "$1" ;;
        *.tar.xz)  tar xJf "$1" ;;
        *.bz2)     bunzip2 "$1" ;;
        *.gz)      gunzip "$1" ;;
        *.tar)     tar xf "$1" ;;
        *.tbz2)    tar xjf "$1" ;;
        *.tgz)     tar xzf "$1" ;;
        *.zip)     unzip "$1" ;;
        *.Z)       uncompress "$1" ;;
        *.7z)      7z x "$1" ;;
        *.rar)     unrar x "$1" ;;
        *)         echo "Cannot extract '$1': unrecognized format" >&2; return 1 ;;
    esac
}


# --- Docker Helper Functions ---
if command -v docker >/dev/null 2>&1; then
    # Get a container's IP address.
    function dip() {
        if [ -z "$1" ]; then
            echo "Usage: dip <container_name_or_id>" >&2; return 1;
        fi
        docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$1"
    }

    # Build a Docker image with a given tag.
    function dbu() {
        if [ -z "$1" ]; then
            echo "Usage: dbu <image_tag>" >&2; return 1;
        fi
        docker build -t="$1" .
    }

    # Build a Docker image with no cache.
    function dbunc() {
        if [ -z "$1" ]; then
            echo "Usage: dbunc <image_tag>" >&2; return 1;
        fi
        docker build --no-cache -t="$1" .
    }

    # Bash into a running container by name.
    function dbash() {
        if [ -z "$1" ]; then
            echo "Usage: dbash <container_name>" >&2; return 1;
        fi
        docker exec -it "$(docker ps -aqf "name=$1")" bash
    }

    # Show all docker-related aliases.
    function dalias() {
        alias | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/" | sed "s/['\"]//g" | sort
    }
fi

# --- Security & Network Analysis Functions ---
# These are too complex for aliases (loops, temp files, multi-step logic).

# Top 20 IPs by connection count.
function conncount() {
    ss -tun | awk 'NR>1{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -20
}

# TCP connection count grouped by state.
function connstate() {
    ss -tan | awk 'NR>1{print $1}' | sort | uniq -c | sort -rn
}

# Detect SYN flood: IPs with most half-open connections.
function synflood() {
    ss -tan state syn-recv | awk 'NR>1{print $4}' | rev | cut -d: -f2- | rev | sort | uniq -c | sort -rn | head -20
}

# Top brute-force IPs from SSH failures in the last hour.
function bruteforce() {
    sudo journalctl -u sshd --since "1h ago" 2>/dev/null \
        | grep 'Failed' \
        | awk '{print $(NF-3)}' \
        | sort | uniq -c | sort -rn | head -20
}

# Detect hidden PIDs: compare ps output against /proc entries.
function pshidden() {
    local ps_pids proc_pids
    ps_pids=$(ps -eo pid --no-headers | awk '{print $1}' | sort -n)
    proc_pids=$(ls /proc 2>/dev/null | grep -E '^[0-9]+$' | sort -n)
    local hidden
    hidden=$(comm -13 <(echo "$ps_pids") <(echo "$proc_pids"))
    if [ -n "$hidden" ]; then
        echo "Hidden PIDs (in /proc but not in ps):"
        echo "$hidden"
    else
        echo "No hidden PIDs detected."
    fi
}

# Test which TLS protocol versions a server supports.
# Usage: sslprotos host:port
function sslprotos() {
    if [ -z "$1" ]; then
        echo "Usage: sslprotos <host:port>" >&2; return 1
    fi
    local proto
    for proto in ssl3 tls1 tls1_1 tls1_2 tls1_3; do
        if echo | openssl s_client -"$proto" -connect "$1" 2>/dev/null | grep -q 'Protocol'; then
            printf "  %-8s %s\n" "$proto:" "YES"
        else
            printf "  %-8s %s\n" "$proto:" "NO"
        fi
    done
}

# Watch for kernel module changes over a 5-second window.
function modwatch() {
    local before after
    before=$(lsmod | awk 'NR>1{print $1}' | sort)
    echo "Sampling loaded modules... (5 seconds)"
    sleep 5
    after=$(lsmod | awk 'NR>1{print $1}' | sort)
    local added removed
    added=$(comm -13 <(echo "$before") <(echo "$after"))
    removed=$(comm -23 <(echo "$before") <(echo "$after"))
    if [ -n "$added" ]; then
        echo "Modules ADDED:"
        echo "$added"
    fi
    if [ -n "$removed" ]; then
        echo "Modules REMOVED:"
        echo "$removed"
    fi
    if [ -z "$added" ] && [ -z "$removed" ]; then
        echo "No module changes detected."
    fi
}

# Display key network-related kernel security parameters.
function securenet() {
    echo "Network Security Parameters:"
    echo "  ip_forward:           $(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null || echo 'N/A')"
    echo "  tcp_syncookies:       $(cat /proc/sys/net/ipv4/tcp_syncookies 2>/dev/null || echo 'N/A')"
    echo "  icmp_echo_ignore_all: $(cat /proc/sys/net/ipv4/icmp_echo_ignore_all 2>/dev/null || echo 'N/A')"
    echo "  rp_filter:            $(cat /proc/sys/net/ipv4/conf/all/rp_filter 2>/dev/null || echo 'N/A')"
    echo "  accept_redirects:     $(cat /proc/sys/net/ipv4/conf/all/accept_redirects 2>/dev/null || echo 'N/A')"
    echo "  accept_source_route:  $(cat /proc/sys/net/ipv4/conf/all/accept_source_route 2>/dev/null || echo 'N/A')"
    echo "  log_martians:         $(cat /proc/sys/net/ipv4/conf/all/log_martians 2>/dev/null || echo 'N/A')"
    echo "  send_redirects:       $(cat /proc/sys/net/ipv4/conf/all/send_redirects 2>/dev/null || echo 'N/A')"
}

# Combined kernel hardening status overview.
function hardencheck() {
    echo "Kernel Hardening Status:"
    echo "  ASLR:             $(cat /proc/sys/kernel/randomize_va_space 2>/dev/null || echo 'N/A') (2=full)"
    echo "  ptrace_scope:     $(cat /proc/sys/kernel/yama/ptrace_scope 2>/dev/null || echo 'N/A') (1=restricted)"
    echo "  kptr_restrict:    $(cat /proc/sys/kernel/kptr_restrict 2>/dev/null || echo 'N/A') (1+=hidden)"
    echo "  dmesg_restrict:   $(cat /proc/sys/kernel/dmesg_restrict 2>/dev/null || echo 'N/A') (1=restricted)"
    echo "  core_pattern:     $(cat /proc/sys/kernel/core_pattern 2>/dev/null || echo 'N/A')"
    echo "  unprivileged_bpf: $(cat /proc/sys/kernel/unprivileged_bpf_disabled 2>/dev/null || echo 'N/A') (1=disabled)"
    echo "  perf_event:       $(cat /proc/sys/kernel/perf_event_paranoid 2>/dev/null || echo 'N/A') (2+=restricted)"
    echo ""
    securenet
}

# Scan a port range on a target using bash /dev/tcp (no extra tools).
# Usage: portscan <host> [start_port] [end_port]
function portscan() {
    local host="${1:?Usage: portscan <host> [start_port] [end_port]}"
    local start="${2:-1}"
    local end="${3:-1024}"
    echo "Scanning $host ports $start-$end..."
    local port
    for (( port=start; port<=end; port++ )); do
        (echo >/dev/tcp/"$host"/"$port") 2>/dev/null && echo "  Port $port: OPEN"
    done
    echo "Scan complete."
}

# Quick system security summary.
function secaudit() {
    echo "=== Security Audit Summary ==="
    echo ""
    echo "--- Users with UID 0 ---"
    awk -F: '$3==0{print "  "$1}' /etc/passwd
    echo ""
    echo "--- Accounts that can log in ---"
    grep -v '/nologin\|/false' /etc/passwd | awk -F: '{print "  "$1" ("$7")"}'
    echo ""
    echo "--- SUID binaries ---"
    find / -xdev -type f -perm -4000 -exec ls -la {} \; 2>/dev/null | awk '{print "  "$NF}'
    echo ""
    echo "--- World-writable files (excl /proc /sys) ---"
    find / -xdev -type f -perm -0002 2>/dev/null | head -20 | awk '{print "  "$0}'
    echo ""
    echo "--- Listening services ---"
    ss -tulnp 2>/dev/null | awk 'NR>1{print "  "$0}'
    echo ""
    echo "--- Last 5 logins ---"
    last -5 -a 2>/dev/null | head -5 | awk '{print "  "$0}'
    echo ""
    hardencheck
}


# --- Podman Helper Functions ---
if command -v podman >/dev/null 2>&1; then
    function palias() {
        alias | grep 'podman' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/" | sed "s/['\"]//g" | sort
    }
fi

# --- Kubernetes Helper Functions ---
if command -v kubectl >/dev/null 2>&1; then
    function kalias() {
        alias | grep 'kubectl' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/" | sed "s/['\"]//g" | sort
    }
fi
