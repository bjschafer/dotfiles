if (( $+commands[fzf] )) ; then
    test -r "$HOME/.fzf/bin" && source "$HOME/.fzf/bin"
    if (( $+commands[rg] )); then
        export FZF_DEFAULT_COMMAND='rg -l --hidden -g "" --ignore .git/'
    elif (( $+commands[ag] )) ; then
        export FZF_DEFAULT_COMMAND='ag -l --hidden -g "" --ignore .git/'
    fi

    export FZF_DEFAULT_OPTS=" \
        --color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
        --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
        --color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284"
fi

source_if_exists "$XDG_DATA_HOME/fzf/fzf.zsh"
source_if_exists "$XDG_DATA_HOME/fzf-git/fzf-git.sh"
