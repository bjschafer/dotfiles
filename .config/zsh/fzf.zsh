if (( $+commands[fzf] )) ; then
    test -r "$HOME/.fzf/bin" && source "$HOME/.fzf/bin"
    if (( $+commands[rg] )); then
        export FZF_DEFAULT_COMMAND='rg -l --hidden -g "" --ignore .git/'
    elif (( $+commands[ag] )) ; then
        export FZF_DEFAULT_COMMAND='ag -l --hidden -g "" --ignore .git/'
    fi
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
