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
