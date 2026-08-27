##############################
# completion system init     #
##############################
setopt nomenucomplete # do not autoselect the first completion entry
setopt automenu       # do show menu on consecutive tabs
setopt completeinword
setopt alwaystoend

# Docker Desktop writes a second compinit call to ~/.zshrc.local when it adds
# this path. Load the path here so the existing cached compinit sees it.
[[ -d "${HOME}/.docker/completions" ]] && fpath=("${HOME}/.docker/completions" $fpath)

# ${ZDOTDIR}/completions and ${ZSH_CACHE_DIR}/completions are meant to
# override anything vendored elsewhere in fpath, but 10-environment.zsh
# prepends Homebrew's site-functions afterward, pushing them back.
# Re-prioritize them here, right before compinit builds its function map.
fpath=(
    "${ZDOTDIR}/completions"
    "${ZSH_CACHE_DIR}/completions"
    ${fpath:#(${ZDOTDIR}/completions|${ZSH_CACHE_DIR}/completions)}
)

# Initialize completion system (only regenerate .zcompdump once per day)
autoload -Uz compinit
if [[ -n ${ZSH_COMPDUMP}(#qN.mh+24) ]]; then
    compinit -d "$ZSH_COMPDUMP"
else
    compinit -C -d "$ZSH_COMPDUMP"
fi

# A fresh Docker install can arrive before the daily compdump rebuild.
if [[ -r "${HOME}/.docker/completions/_docker" ]]; then
    autoload -Uz _docker
    compdef _docker docker
fi

# automatically load bash completion functions
autoload -U +X bashcompinit && bashcompinit

##############################
# completion styling         #
##############################
# case insensitive (all), partial-word and substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show
