#
# REGISTRY: lib/aliases.sh
#
# Defines safe, convenient, and production-ready command aliases for
# general use, development, and operations.
#

#
# IMPLEMENTATION
#

# --- File System & Colors ---
if command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias ll='ls -alF --color=auto'
    alias la='ls -A --color=auto'
    alias ltr='ls -altrF --color=auto' # List by time, newest last
fi
alias rm='rm -i'; alias cp='cp -i'; alias mv='mv -i'
alias mkp='mkdir -p'
alias chom='chmod 755'
alias chox='chmod +x'


# --- Search & Grep ---
alias ffind='find . -name' # Find files by name, e.g., ffind "*.log"
# Grep recursively, with line numbers, case-insensitive, and excluding .git
alias grepg='grep --color=auto -inr --exclude-dir=.git'


# --- Navigation ---
alias ..='cd ..'; alias ...='cd ../..'; alias ....='cd ../../..'; alias .....='cd ../../../..'


# --- General Convenience ---
alias h='history'; alias c='clear'; alias reload='source ~/.bashrc && echo "Bash reloaded"'
alias serve='python3 -m http.server'


# --- System & Process Management ---
# Use htop if available, otherwise fall back to top
alias top='command -v htop &>/dev/null && htop || top'
alias up='uptime -p'
alias psa='ps aux'
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e" # Usage: psg nginx
alias memtop='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head' # Show top 10 memory hogs
alias cputop='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head' # Show top 10 CPU hogs
alias schownme='sudo chown -R $(whoami):$(whoami) .' # Sudo-chown current dir to me


# --- Networking & Diagnostics ---
alias ports='netstat -tulanp'
alias curH='curl -I' # Get headers only
alias curlt='curl -w "dns: %{time_namelookup}s | connect: %{time_connect}s | total: %{time_total}s\n" -o /dev/null -s' # Get request timing info
# WARNING: The 'sshn' alias bypasses host key checking, use only for trusted, ephemeral connections.
alias sshn='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'


# --- Archive Management ---
alias targz='tar -czvf' # Create a .tar.gz archive, e.g., targz archive.tar.gz /path
alias untar='tar -xzvf' # Extract a .tar.gz archive


# --- Git ---
if command -v git >/dev/null 2>&1; then
    alias gs='git status'; alias ga='git add'; alias gc='git commit -v'; alias gd='git diff'
    alias gco='git checkout'; alias gb='git branch'; alias gl='git log --oneline --graph --decorate --all'
    alias gp='git push'; alias gpl='git pull'
fi


# --- DevOps: Docker & K8s ---
if command -v docker >/dev/null 2>&1; then
    alias d='docker'; alias dps='docker ps'; alias dpsa='docker ps -a'
    alias di='docker images'; alias dlogs='docker logs -f'; alias dexec='docker exec -it'
    alias dstopa='docker stop $(docker ps -aq)'; alias drma='docker rm $(docker ps -aq)'
    alias drmfa='docker stop $(docker ps -aq) && docker rm $(docker ps -aq)'
    alias drmia='docker rmi $(docker images -q -a)'
    if command -v docker compose >/dev/null 2>&1; then
        alias dc='docker compose'; alias dcup='docker compose up -d'; alias dcdown='docker compose down';
        alias dcr='docker compose restart'; alias dcb='docker compose build'; alias dcps='docker compose ps'; alias dclogs='docker compose logs -f'
    fi
fi
if command -v kubectl >/dev/null 2>&1; then
    alias k='kubectl'; alias kget='kubectl get'; alias kdesc='kubectl describe'; alias klogs='kubectl logs -f'
    alias kexec='kubectl exec -it'; alias ka='kubectl apply -f'; alias kd='kubectl delete -f'
fi


# --- Language Development (Python, Node, Ruby, Rust) ---
if command -v python3 >/dev/null 2>&1; then
    alias py='python3'; alias pip='python3 -m pip'; alias venv='python3 -m venv venv'; alias pya='source venv/bin/activate'
fi
if command -v npm >/dev/null 2>&1; then
    alias ni='npm install'; alias nis='npm install --save'; alias nid='npm install --save-dev'; alias nr='npm run'; alias nt='npm test'
fi
if command -v bundle >/dev/null 2>&1; then
    alias bi='bundle install'; alias be='bundle exec'; alias rs='bundle exec rspec'; alias rc='bundle exec rubocop'; alias rg='bundle exec rails g'
fi
if command -v cargo >/dev/null 2>&1; then
    alias rcb='cargo build'; alias rcr='cargo run'; alias rct='cargo test'; alias rcc='cargo check'; alias rci='cargo install'
fi
