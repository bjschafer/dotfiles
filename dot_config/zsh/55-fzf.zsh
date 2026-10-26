##############################
# fzf setup                  #
##############################

# fzf 0.48+ provides shell integration via `fzf --zsh`.
# Cache it so we don't spawn the binary on every shell start.
local fzf_cache="${XDG_CACHE_HOME:-$HOME/.cache}/fzf/zsh-integration.zsh"
local fzf_version_cache="${fzf_cache}.version"
local cached_version=""
[[ -f "$fzf_version_cache" ]] && cached_version="$(<"$fzf_version_cache")"
if [[ ! -f "$fzf_cache" ]] || [[ "$(fzf --version 2>/dev/null)" != "$cached_version" ]]; then
    mkdir -p "${fzf_cache:h}"
    fzf --zsh >| "$fzf_cache" 2>/dev/null
    fzf --version >| "$fzf_version_cache" 2>/dev/null
fi
[[ -s "$fzf_cache" ]] && source "$fzf_cache"

##############################
# fzf configuration          #
##############################
if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
elif (( $+commands[rg] )); then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
fi

# Catppuccin Frappe colors
export FZF_DEFAULT_OPTS=" \
    --color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
    --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
    --color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284"

source_if_exists "$XDG_DATA_HOME/fzf-git/fzf-git.sh"
