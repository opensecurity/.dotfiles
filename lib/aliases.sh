#
# REGISTRY: lib/aliases.sh
#
# Defines safe, convenient, and production-ready command aliases.
# All external tool sections are guarded with command -v (shell builtin)
# for fast loading even when tools are absent.
#

# ============================================================================
#  File System & Colors
# ============================================================================
if command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias l='ls -al'
alias ll='ls -lah'
alias la='ls -A'
alias ltr='ls -altrF'
alias lth='ls -alt | head'
alias lh='ls -Shl | less'
alias lsd='ls -ld */'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'
alias chom='chmod 755'
alias chox='chmod +x'

# Rsync copy with progress
alias cpv='rsync -ah --progress'

# File comparison with color if available
if command -v colordiff >/dev/null 2>&1; then
    alias diff='colordiff'
fi


# ============================================================================
#  Search
# ============================================================================
alias ff='find . -type f -name'
alias fd='find . -type d -name'
alias grepg='grep --color=auto -inr --exclude-dir=.git'


# ============================================================================
#  Navigation
# ============================================================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'


# ============================================================================
#  General Convenience
# ============================================================================
alias h='history'
alias hg='history | grep'
alias c='clear'
alias cls='clear'
alias j='jobs -l'
alias reload='source ~/.bashrc && echo "Bash reloaded"'
alias path='echo $PATH | tr ":" "\n"'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias timestamp='date +%s'
alias week='date +%V'
alias tailf='tail -f -n 100'

# Quick HTTP servers
alias serve='python3 -m http.server'
alias httpy='python3 -m http.server 8000'
if command -v ruby >/dev/null 2>&1; then alias httprb='ruby -run -e httpd . -p 8000'; fi
if command -v php >/dev/null 2>&1; then alias httphp='php -S localhost:8000'; fi

# Quick edit common config files
alias bashrc='${EDITOR:-nano} ~/.bashrc'
alias vimrc='${EDITOR:-nano} ~/.vimrc'
alias hosts='sudo ${EDITOR:-nano} /etc/hosts'
alias sshconf='${EDITOR:-nano} ~/.ssh/config'


# ============================================================================
#  System & Process Management
# ============================================================================
alias top='command -v htop &>/dev/null && htop || command top'
alias up='uptime -p'
alias psa='ps aux'
alias psg='ps aux | grep -v grep | grep -i'
alias psmem='ps aux --sort=-%mem | head -20'
alias pscpu='ps aux --sort=-%cpu | head -20'
alias memtop='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head'
alias cputop='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head'

# Disk usage
alias dfh='df -h'
alias dfi='df -i'
alias duh='du -h'
alias duf='du -sh * | sort -rh'

# File info
alias fileinfo='file -b'
alias filemime='file -i'


# ============================================================================
#  Archive Management
# ============================================================================
alias tarc='tar -czvf'
alias tarx='tar -xzvf'
alias tarbz='tar -cjvf'
alias tarxbz='tar -xjvf'
alias untar='tar -xzvf'


# ============================================================================
#  Network & IP
# ============================================================================
alias extip='curl -s ipinfo.io/ip'
alias localip="hostname -I | awk '{print \$1}'"
alias myip='curl -s ipinfo.io | python3 -m json.tool'
alias ping='ping -c 5'
alias dig='dig +nocmd'
alias http='curl -I'
alias headers='curl -I'
alias curlt='curl -w "dns: %{time_namelookup}s | connect: %{time_connect}s | total: %{time_total}s\n" -o /dev/null -s'
if command -v whois >/dev/null 2>&1; then alias whois='whois -H'; fi

# SSH
alias ssh='ssh -o StrictHostKeyChecking=accept-new'
alias sshn='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
alias ssha='ssh-add'
alias sshkeys='ls -la ~/.ssh/'
alias sshconfig='${EDITOR:-nano} ~/.ssh/config'

# Network file transfer
alias sftp='sftp -oBatchMode=no'
alias scp='scp -oBatchMode=no'

# Ports and connections
alias listening='lsof -i -P -n | grep LISTEN'
alias established='lsof -i -P -n | grep ESTABLISHED'
alias openfiles='lsof -c'


# ============================================================================
#  Git
# ============================================================================
if command -v git >/dev/null 2>&1; then
    # Status & info
    alias gs='git status -sb'
    alias gd='git diff'
    alias gds='git diff --staged'
    alias gdn='git diff --name-only'
    alias gl='git log --oneline --graph --decorate -20'
    alias gla='git log --oneline --graph --decorate --all'
    alias glp='git log -p -3'
    alias gbl='git blame -b -w'

    # Staging & commits
    alias ga='git add'
    alias gap='git add -p'
    alias gc='git commit -v'
    alias gcm='git commit -m'
    alias gca='git commit --amend'
    alias gcan='git commit --amend --no-edit'

    # Branching
    alias gco='git checkout'
    alias gcob='git checkout -b'
    alias gb='git branch'
    alias gbd='git branch -d'
    alias gbD='git branch -D'

    # Remote
    alias gp='git push'
    alias gpf='git push --force-with-lease'
    alias gpl='git pull --rebase'
    alias gf='git fetch --all --prune'

    # Merge & rebase
    alias gm='git merge'
    alias gms='git merge --squash'
    alias gr='git rebase'
    alias grc='git rebase --continue'
    alias gra='git rebase --abort'

    # Stash
    alias gst='git stash'
    alias gstp='git stash pop'
    alias gstl='git stash list'
    alias gstd='git stash drop'

    # Misc
    alias gcp='git cherry-pick'
    alias gcpa='git cherry-pick --abort'
    alias gt='git tag'
    alias gclean='git clean -fd'
    alias greset='git reset HEAD'
    alias gresethard='git reset --hard HEAD'
    alias gwip='git add -A && git commit -m "WIP"'
    alias gunwip='git log -1 --format="%s" | grep -q "WIP" && git reset HEAD~1'
fi


# ============================================================================
#  Docker
# ============================================================================
if command -v docker >/dev/null 2>&1; then
    # Container management
    alias d='docker'
    alias dps='docker ps'
    alias dpa='docker ps -a'
    alias dst='docker stats'
    alias dstart='docker start'
    alias dstop='docker stop'
    alias drestart='docker restart'
    alias dexec='docker exec -it'
    alias drun='docker run'
    alias dlogs='docker logs'
    alias dlogsf='docker logs -f'
    alias dtop='docker top'
    alias dkill='docker kill'
    alias dwait='docker wait'
    alias drm='docker rm'
    alias drma='docker rm $(docker ps -aq) 2>/dev/null'
    alias dstopa='docker stop $(docker ps -aq) 2>/dev/null'

    # Image management
    alias di='docker images'
    alias dimages='docker images'
    alias dinspect='docker image inspect'
    alias dremove='docker image rm'
    alias dpull='docker pull'
    alias dpush='docker push'
    alias dprune='docker system prune -af'
    alias dclean='docker system prune -af --volumes'
    alias ddangling='docker images -f "dangling=true" -q | xargs -r docker rmi'

    # Volume management
    alias dvolumes='docker volume ls'
    alias dvinspect='docker volume inspect'
    alias dvr='docker volume rm'
    alias dvprune='docker volume prune -f'

    # Network management
    alias dnetworks='docker network ls'
    alias dninspect='docker network inspect'
    alias dnrm='docker network rm'

    # Docker Compose (v2 plugin)
    if docker compose version &>/dev/null; then
        alias dc='docker compose'
        alias dcup='docker compose up -d'
        alias dcupf='docker compose up'
        alias dcdown='docker compose down'
        alias dcdownv='docker compose down -v'
        alias dcr='docker compose restart'
        alias dcb='docker compose build'
        alias dcbnc='docker compose build --no-cache'
        alias dcpull='docker compose pull'
        alias dcps='docker compose ps'
        alias dclogs='docker compose logs -f'
        alias dcexec='docker compose exec'
        alias dcrun='docker compose run --rm'
    fi
fi


# ============================================================================
#  Podman
# ============================================================================
if command -v podman >/dev/null 2>&1; then
    alias pps='podman ps'
    alias ppa='podman ps -a'
    alias pst='podman stats'
    alias pstart='podman start'
    alias pstop='podman stop'
    alias prestart='podman restart'
    alias pexec='podman exec -it'
    alias prun='podman run'
    alias plogs='podman logs'
    alias plogsf='podman logs -f'
    alias prm='podman rm'
    alias prma='podman rm -a'

    alias pimages='podman images'
    alias ppull='podman pull'
    alias ppush='podman push'
    alias prmi='podman rmi'
    alias pprune='podman system prune -af'
    alias pclean='podman system prune -af --volumes'

    alias pvolumes='podman volume ls'
    alias pvprune='podman volume prune -f'
    alias pnetworks='podman network ls'

    # Podman Compose
    if command -v podman-compose >/dev/null 2>&1; then
        alias pcup='podman-compose up'
        alias pcupd='podman-compose up -d'
        alias pcdown='podman-compose down'
        alias pcps='podman-compose ps'
        alias pclogs='podman-compose logs'
    fi

    # Pod management
    alias ppods='podman pod ls'
    alias ppodstart='podman pod start'
    alias ppodstop='podman pod stop'
    alias ppodrm='podman pod rm'
fi


# ============================================================================
#  Kubernetes
# ============================================================================
if command -v kubectl >/dev/null 2>&1; then
    alias k='kubectl'

    # Get resources
    alias kgp='kubectl get pods'
    alias kgpa='kubectl get pods --all-namespaces'
    alias kgd='kubectl get deployments'
    alias kgs='kubectl get services'
    alias kgn='kubectl get nodes'
    alias kgi='kubectl get ingress'
    alias kgns='kubectl get namespaces'
    alias kgcm='kubectl get configmaps'
    alias kgsec='kubectl get secrets'
    alias kgpv='kubectl get pv'
    alias kgpvc='kubectl get pvc'
    alias kge='kubectl get events --sort-by=".lastTimestamp"'

    # Describe resources
    alias kd='kubectl describe'
    alias kdp='kubectl describe pod'
    alias kdd='kubectl describe deployment'
    alias kds='kubectl describe service'
    alias kdn='kubectl describe node'

    # Logs
    alias kl='kubectl logs'
    alias klf='kubectl logs -f'
    alias klt='kubectl logs --tail=100'

    # Operations
    alias kex='kubectl exec -it'
    alias kaf='kubectl apply -f'
    alias kdf='kubectl delete -f'
    alias kpf='kubectl port-forward'
    alias kctx='kubectl config current-context'
    alias kns='kubectl config set-context --current --namespace'

    # Monitoring
    alias ktop='kubectl top pods'
    alias ktopn='kubectl top nodes'

    # Rollouts
    alias kroll='kubectl rollout status'
    alias krollr='kubectl rollout restart'
    alias krollh='kubectl rollout history'
    alias krollu='kubectl rollout undo'

    # Node management
    alias kdrain='kubectl drain --ignore-daemonsets --delete-emptydir-data'
    alias kcordon='kubectl cordon'
    alias kuncordon='kubectl uncordon'
fi


# ============================================================================
#  Helm
# ============================================================================
if command -v helm >/dev/null 2>&1; then
    alias hls='helm list'
    alias hlsa='helm list --all-namespaces'
    alias hi='helm install'
    alias hu='helm upgrade'
    alias hui='helm upgrade --install'
    alias hun='helm uninstall'
    alias hs='helm search repo'
    alias hsh='helm search hub'
    alias hru='helm repo update'
    alias hra='helm repo add'
    alias hrl='helm repo list'
    alias hv='helm version'
fi


# ============================================================================
#  Terraform / OpenTofu
# ============================================================================
if command -v terraform >/dev/null 2>&1 || command -v tofu >/dev/null 2>&1; then
    # Prefer tofu if available, otherwise terraform.
    if command -v tofu >/dev/null 2>&1; then
        _tf_cmd="tofu"
    else
        _tf_cmd="terraform"
    fi

    alias tf="$_tf_cmd"
    alias tfi="$_tf_cmd init"
    alias tfp="$_tf_cmd plan"
    alias tfa="$_tf_cmd apply"
    alias tfaa="$_tf_cmd apply -auto-approve"
    alias tfd="$_tf_cmd destroy"
    alias tfs="$_tf_cmd state"
    alias tfsl="$_tf_cmd state list"
    alias tfss="$_tf_cmd state show"
    alias tfo="$_tf_cmd output"
    alias tfv="$_tf_cmd validate"
    alias tff="$_tf_cmd fmt -recursive"
    alias tfw="$_tf_cmd workspace"
    alias tfwl="$_tf_cmd workspace list"
    alias tfws="$_tf_cmd workspace select"
    alias tfwn="$_tf_cmd workspace new"
    alias tfimport="$_tf_cmd import"
    alias tfrefresh="$_tf_cmd refresh"

    unset _tf_cmd
fi


# ============================================================================
#  Security: Network Reconnaissance & Analysis
# ============================================================================
alias conns='ss -tunap'
alias estab='ss -tunp state established'
alias timewait='ss -tan state time-wait | wc -l'
alias rawsock='ss -w -a -p'
alias ifaces='ip -br -c addr'
alias routes='ip -c route'
alias neigh='ip -c neigh'
alias gw="ip route | awk '/default/{print \$3}'"
alias macaddr="ip link | awk '/ether/{print \$2}'"
alias promisc='ip link | grep -i promisc'
alias pubip='curl -s ifconfig.me'
alias dnsleak='curl -s https://1.1.1.1/cdn-cgi/trace'


# ============================================================================
#  Security: SSL/TLS & Certificates
# ============================================================================
alias sslcheck='openssl s_client -connect'
alias sslscan='openssl s_client -connect'
alias sslcert='openssl x509 -noout -text -in'
alias sslexpiry='openssl s_client -connect 2>/dev/null | openssl x509 -noout -dates'
alias certdates='openssl s_client -connect 2>/dev/null | openssl x509 -noout -dates'
alias certsubj='openssl s_client -connect 2>/dev/null | openssl x509 -noout -subject -issuer'
alias certsan='openssl s_client -connect 2>/dev/null | openssl x509 -noout -ext subjectAltName'
alias certfinger='openssl s_client -connect 2>/dev/null | openssl x509 -noout -fingerprint -sha256'
alias sslverify='openssl verify'
alias sslhash='openssl x509 -noout -hash -in'
alias selfsign='openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes -keyout key.pem -out cert.pem -subj /CN=localhost'
alias csrgen='openssl req -new -newkey rsa:4096 -nodes -keyout key.pem -out request.csr'


# ============================================================================
#  Security: Hashing & File Integrity
# ============================================================================
alias sha1='shasum -a 1'
alias sha256='shasum -a 256'
alias sha512='shasum -a 512'
alias hashfile='sha256sum'
alias hashverify='sha256sum -c'
alias hashdir='find . -type f -exec sha256sum {} + | sort -k2'
alias fperms="stat -c '%a %U:%G %n'"


# ============================================================================
#  Security: Password & Key Generation
# ============================================================================
alias genpass='openssl rand -base64 32'
alias genpass16='openssl rand -base64 16'
alias randpass='openssl rand -base64 48 | tr -d "/+=" | head -c 32; echo'
alias randhex='openssl rand -hex 32'
alias genkey='openssl rand -hex 32'
alias genuuid='python3 -c "import uuid; print(uuid.uuid4())"'


# ============================================================================
#  Security: Encoding / Decoding
# ============================================================================
alias b64e='base64'
alias b64d='base64 -d'
alias urlencode='python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))"'
alias urldecode='python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))"'


# ============================================================================
#  Security: File Permission Auditing
# ============================================================================
alias suid='find / -xdev -type f -perm -4000 -exec ls -la {} \; 2>/dev/null'
alias sgid='find / -xdev -type f -perm -2000 -exec ls -la {} \; 2>/dev/null'
alias worldw='find / -xdev -type f -perm -0002 -exec ls -la {} \; 2>/dev/null'
alias worldwd='find / -xdev -type d -perm -0002 -exec ls -lad {} \; 2>/dev/null'
alias noowner='find / -xdev \( -nouser -o -nogroup \) -exec ls -la {} \; 2>/dev/null'
alias recentmod='find / -xdev -type f -mmin -60 -exec ls -la {} \; 2>/dev/null'
alias largefiles='find / -xdev -type f -size +100M -exec ls -lh {} \; 2>/dev/null | sort -k5 -rh'
alias exeintmp='find /tmp /var/tmp /dev/shm -type f -executable 2>/dev/null'
alias coredumps='find / -xdev -name "core" -o -name "core.*" 2>/dev/null'
alias dotfilefind='find / -xdev -name ".*" -type f 2>/dev/null | grep -v -E "/(\.git|\.cache|\.local)/"'
if command -v lsattr >/dev/null 2>&1; then
    alias immutable='lsattr -R / 2>/dev/null | grep "\-i\-"'
fi


# ============================================================================
#  Security: Process & Runtime Forensics
# ============================================================================
alias pstree='ps -ejH'
alias psnet='lsof -i -n -P'
alias psdeleted='lsof +L1'
alias psnoparent="ps -eo pid,ppid,comm | awk '\$2==1{print}'"
alias psenv='cat /proc/$$/environ 2>/dev/null | tr "\0" "\n"'
alias fdcount="lsof -n 2>/dev/null | awk '{print \$1}' | sort | uniq -c | sort -rn | head -20"
alias stracepid='sudo strace -fp'
alias bindeps='ldd'
alias binstrings='strings -a'
alias deleted='sudo find /proc/*/exe -type l 2>/dev/null | xargs ls -la 2>/dev/null | grep deleted'


# ============================================================================
#  Security: User & Authentication Auditing
# ============================================================================
alias whois_on='w -h'
alias lastlogins='last -20'
alias loginssh='last -i -20'
alias lastlog_active='lastlog | grep -v "Never"'
alias failedlogins='sudo lastb -20 2>/dev/null || journalctl -u sshd --since "1 week ago" 2>/dev/null | grep "Failed"'
alias authlog='sudo tail -f /var/log/auth.log 2>/dev/null || sudo tail -f /var/log/secure'
alias sshlogins='grep "Accepted" /var/log/auth.log 2>/dev/null || journalctl -u sshd 2>/dev/null | grep "Accepted"'
alias nologin='grep -v "/nologin\|/false" /etc/passwd'
alias uid0="awk -F: '\$3==0{print}' /etc/passwd"
alias emptypass="sudo awk -F: '(\$2==\"\"){print \$1}' /etc/shadow 2>/dev/null"
alias passexpiry='sudo chage -l'
alias sudoers='grep -v "^#\|^$" /etc/sudoers /etc/sudoers.d/* 2>/dev/null'
alias sshkeysall='find /home -name authorized_keys -exec ls -la {} \; 2>/dev/null'
alias loginshells='cat /etc/shells'


# ============================================================================
#  JSON / YAML / Data
# ============================================================================
alias jsonpp='python3 -m json.tool'
alias jsonval='python3 -c "import json,sys; json.load(sys.stdin); print(\"Valid JSON\")"'
alias yamlval='python3 -c "import yaml,sys; yaml.safe_load(sys.stdin); print(\"Valid YAML\")"'
alias csv='column -t -s,'

if command -v jq >/dev/null 2>&1; then
    alias jqkeys='jq keys'
    alias jqlen='jq length'
    alias jqraw='jq -r'
fi


# ============================================================================
#  Development: Python
# ============================================================================
if command -v python3 >/dev/null 2>&1; then
    alias py='python3'
    alias pip='python3 -m pip'
    alias pipi='python3 -m pip install'
    alias pipu='python3 -m pip install --upgrade'
    alias pipun='python3 -m pip uninstall'
    alias pipf='python3 -m pip freeze'
    alias pipr='python3 -m pip install -r requirements.txt'
    alias venv='python3 -m venv .venv'
    alias activate='source .venv/bin/activate'
fi


# ============================================================================
#  Development: Node.js / NPM / Yarn
# ============================================================================
if command -v npm >/dev/null 2>&1; then
    alias ni='npm install'
    alias nig='npm install -g'
    alias nid='npm install --save-dev'
    alias nrs='npm run start'
    alias nrb='npm run build'
    alias nrt='npm run test'
    alias nrl='npm run lint'
    alias nrd='npm run dev'
    alias nrw='npm run watch'
    alias nci='npm ci'
    alias nau='npm audit'
    alias nauf='npm audit fix'
fi
if command -v yarn >/dev/null 2>&1; then
    alias yi='yarn install'
    alias ya='yarn add'
    alias yad='yarn add --dev'
    alias yrm='yarn remove'
    alias yrs='yarn start'
    alias yrb='yarn build'
    alias yrt='yarn test'
    alias yrl='yarn lint'
    alias yrd='yarn dev'
fi


# ============================================================================
#  Development: Ruby / Go / Rust / Make
# ============================================================================
if command -v bundle >/dev/null 2>&1; then
    alias be='bundle exec'
    alias bi='bundle install'
    alias bu='bundle update'
    alias bo='bundle outdated'
fi
if command -v go >/dev/null 2>&1; then
    alias gor='go run'
    alias gob='go build'
    alias got='go test ./...'
    alias gotv='go test -v ./...'
    alias gof='go fmt ./...'
    alias govet='go vet ./...'
    alias gomod='go mod tidy'
    alias goget='go get'
fi
if command -v cargo >/dev/null 2>&1; then
    alias cr='cargo run'
    alias cb='cargo build'
    alias cbr='cargo build --release'
    alias ct='cargo test'
    alias cc='cargo check'
    alias cf='cargo fmt'
    alias ccl='cargo clippy'
    alias ca='cargo add'
    alias cw='cargo watch -x run'
fi
alias m='make'
alias mb='make build'
alias mt='make test'
alias mc='make clean'


# ============================================================================
#  Systemd & Services (Linux)
# ============================================================================
if [ "${DOTFILES_OS:-}" = "Linux" ] && command -v systemctl >/dev/null 2>&1; then
    alias sc='systemctl'
    alias scstart='sudo systemctl start'
    alias scstop='sudo systemctl stop'
    alias screstart='sudo systemctl restart'
    alias scstatus='systemctl status'
    alias scenable='sudo systemctl enable'
    alias scdisable='sudo systemctl disable'
    alias screload='sudo systemctl daemon-reload'
    alias sclog='journalctl -u'
    alias sclogf='journalctl -fu'
    alias scfailed='systemctl --failed'
    alias sctimers='systemctl list-timers --all'
fi


# ============================================================================
#  Ansible
# ============================================================================
if command -v ansible >/dev/null 2>&1; then
    alias ans='ansible'
    alias ansp='ansible-playbook'
    alias ansv='ansible-vault'
    alias ansg='ansible-galaxy'
    alias ansi='ansible-inventory'
    alias ansl='ansible-lint'
    alias ansping='ansible all -m ping'
    alias ansfacts='ansible all -m setup'
fi


# ============================================================================
#  AWS CLI
# ============================================================================
if command -v aws >/dev/null 2>&1; then
    alias awswho='aws sts get-caller-identity'
    alias awsregions='aws ec2 describe-regions --output table'
    alias awsec2='aws ec2 describe-instances --output table'
    alias awss3='aws s3 ls'
    alias awslambda='aws lambda list-functions'
    alias awseks='aws eks list-clusters'
    alias awsrds='aws rds describe-db-instances'
    alias awsiam='aws iam list-users'
    alias awslogs='aws logs describe-log-groups'
    alias awscf='aws cloudformation list-stacks'
fi


# ============================================================================
#  Linux-only
# ============================================================================
if [ "${DOTFILES_OS:-}" = "Linux" ]; then
    alias ports='netstat -tuln'
    alias ss='ss -tunlp'
    alias ifc='ifconfig'
    alias arp='arp -a'
    alias mount='mount | column -t'

    # Elevated network tools
    alias tcpdump='sudo tcpdump -i any'
    if command -v mtr >/dev/null 2>&1; then alias mtr='sudo mtr'; fi
    if command -v iftop >/dev/null 2>&1; then alias iftop='sudo iftop -nNP'; fi
    if command -v ngrep >/dev/null 2>&1; then alias ngrep='sudo ngrep -d any'; fi

    # Wireless (NetworkManager)
    if command -v nmcli >/dev/null 2>&1; then
        alias wifi='nmcli device wifi list'
        alias wifion='nmcli radio wifi on'
        alias wifioff='nmcli radio wifi off'
    fi

    # Firewall: iptables inspection (base package on all distros)
    if command -v iptables >/dev/null 2>&1; then
        alias iptlist='sudo iptables -L -n -v --line-numbers'
        alias iptnat='sudo iptables -t nat -L -n -v'
        alias iptmangle='sudo iptables -t mangle -L -n -v'
        alias iptcount='sudo iptables -L -n -v -x'
        alias iptdrop='sudo iptables -L -n -v | grep -i drop'
        alias iptlog='sudo iptables -L -n -v | grep -i log'
    fi

    # Firewall: ufw management
    if command -v ufw >/dev/null 2>&1; then
        alias fws='sudo ufw status verbose'
        alias fwa='sudo ufw allow'
        alias fwi='sudo ufw deny'
        alias fwc='sudo ufw enable'
        alias fwoff='sudo ufw disable'
        alias fwreset='sudo ufw reset'
    fi

    # Network security: /proc/sys tunables
    alias ipfwd='cat /proc/sys/net/ipv4/ip_forward'
    alias synprot='cat /proc/sys/net/ipv4/tcp_syncookies'

    # Log analysis: journalctl / dmesg
    alias authwatch='sudo tail -f /var/log/auth.log 2>/dev/null || sudo journalctl -fu sshd'
    alias sshfail='sudo journalctl -u sshd --since "24h ago" 2>/dev/null | grep "Failed"'
    alias sshaccept='sudo journalctl -u sshd --since "24h ago" 2>/dev/null | grep "Accepted"'
    alias kernerr='dmesg -T --level=err,crit,alert,emerg 2>/dev/null'
    alias kernwarn='dmesg -T --level=warn 2>/dev/null'
    alias oomkills='dmesg -T 2>/dev/null | grep -i "oom-killer\|out of memory"'
    alias segfaults='dmesg -T 2>/dev/null | grep -i segfault'
    alias booterr='journalctl -b -p err 2>/dev/null'
    alias cronlog='sudo journalctl -u cron --since "24h ago" 2>/dev/null'
    alias sulog='sudo journalctl 2>/dev/null | grep -E "su:|sudo:"'

    # Kernel & system hardening checks
    alias aslr='cat /proc/sys/kernel/randomize_va_space'
    alias ptrace='cat /proc/sys/kernel/yama/ptrace_scope 2>/dev/null'
    alias kptr='cat /proc/sys/kernel/kptr_restrict'
    alias dmesgperm='cat /proc/sys/kernel/dmesg_restrict'
    alias coredumpcfg='cat /proc/sys/kernel/core_pattern'
    alias modules='lsmod | sort'

    # Clipboard (X11)
    if command -v xclip >/dev/null 2>&1; then
        alias clip='xclip -selection clipboard'
        alias clippaste='xclip -selection clipboard -o'
    fi
fi


# ============================================================================
#  macOS-only
# ============================================================================
if [ "${DOTFILES_OS:-}" = "Darwin" ]; then
    alias ports='lsof -iTCP -sTCP:LISTEN -n -P'
    alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
    alias mount='mount | column -t'
    alias clip='pbcopy'
    alias clippaste='pbpaste'
fi
