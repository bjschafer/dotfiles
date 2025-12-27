##############################
# fzf setup                  #
##############################

# Modern fzf (0.48+) has built-in shell integration
# Fall back to manual setup for older versions or system packages
_fzf_setup() {
    # Try modern fzf --zsh first (requires fzf 0.48+)
    local fzf_ver="${"$(fzf --version 2>/dev/null)"#fzf }"
    autoload -Uz is-at-least
    if is-at-least 0.48.0 "${${(s: :)fzf_ver}[1]}"; then
        eval "$(fzf --zsh)"
        return 0
    fi

    # Fall back to sourcing shell integration files
    local fzf_dirs=(
        "/opt/homebrew/opt/fzf/shell"
        "/usr/local/opt/fzf/shell"
        "/usr/share/fzf"
        "/usr/share/doc/fzf/examples"
        "${XDG_DATA_HOME:-$HOME/.local/share}/fzf"
        "${HOME}/.fzf/shell"
    )

    for dir in "${fzf_dirs[@]}"; do
        if [[ -f "${dir}/completion.zsh" ]]; then
            source "${dir}/completion.zsh" 2>/dev/null
            source "${dir}/key-bindings.zsh" 2>/dev/null
            return 0
        fi
    done

    return 1
}
_fzf_setup
unfunction _fzf_setup

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
