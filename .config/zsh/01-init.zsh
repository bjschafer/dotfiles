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

export XDG_DATA_HOME="$HOME/.local/share"

export ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"
mkdir -p "${ZSH_CACHE_DIR}/completions"
