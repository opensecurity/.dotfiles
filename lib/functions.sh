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


# --- Docker Helper Functions ---
if command -v docker >/dev/null 2>&1; then
    # Get a container's IP address.
    # Usage: dip <container_name_or_id>
    function dip() {
        if [ -z "$1" ]; then
            echo "Usage: dip <container_name_or_id>" >&2; return 1;
        fi
        docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$1"
    }

    # Build a Docker image with a given tag.
    # Usage: dbu <tag_name>
    function dbu() {
        if [ -z "$1" ]; then
            echo "Usage: dbu <image_tag>" >&2; return 1;
        fi
        docker build -t="$1" .
    }

    # Bash into a running container by name.
    # Usage: dbash <container_name>
    function dbash() {
        if [ -z "$1" ]; then
            echo "Usage: dbash <container_name>" >&2; return 1;
        fi
        docker exec -it "$(docker ps -aqf "name=$1")" bash
    }
fi
