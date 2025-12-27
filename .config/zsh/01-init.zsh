##############################
# XDG base directories       #
##############################
declare -A xdg_dirs
xdg_dirs=(
    [XDG_DATA_HOME]="$HOME/.local/share"
    [XDG_CONFIG_HOME]="$HOME/.config"
    [XDG_STATE_HOME]="$HOME/.local/state"
    [XDG_CACHE_HOME]="$HOME/.cache"
    [XDG_RUNTIME_DIR]="/run/user/$UID"
)

for var default in ${(kv)xdg_dirs}; do
    if [[ -z "${(P)var}" ]]; then
        export "$var"="$default"
    fi
done

##############################
# zsh cache / completions    #
##############################
export ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"
export ZSH_COMPDUMP="${ZSH_CACHE_DIR}/.zcompdump"
mkdir -p "${ZSH_CACHE_DIR}/completions"
fpath=("${ZSH_CACHE_DIR}/completions" $fpath)

##############################
# helper functions           #
##############################
source_if_exists() {
    [[ -r "$1" ]] && source "$1"
}

export_if_exists() {
    [[ -e "$2" ]] && export "$1"="$2"
}

# osfamily returns the system type (darwin, debian, arch, unknown)
osfamily() {
    local verbose="$1"
    if [[ "$OSTYPE" == darwin* ]]; then
        if [[ -n "$verbose" ]]; then
            echo "$OSTYPE"
        else
            echo 'darwin'
        fi
    elif [[ -e '/etc/debian_version' ]]; then
        if [[ -n "$verbose" ]]; then
            cut -d' ' -f1 /etc/issue | tr 'A-Z' 'a-z'
        else
            echo 'debian'
        fi
    elif [[ -e '/etc/arch-release' ]]; then
        if [[ -n "$verbose" ]]; then
            cut -d' ' -f1 /etc/arch-release | tr 'A-Z' 'a-z'
        else
            echo 'arch'
        fi
    else
        echo 'unknown'
    fi
}
