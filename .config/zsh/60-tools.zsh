##############################
# tool integrations          #
##############################

# direnv
if (( $+commands[direnv] )); then
    eval "$(direnv hook zsh)"
fi

# zoxide
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi

# atuin
if (( $+commands[atuin] )); then
    eval "$(atuin init zsh --disable-up-arrow)"
fi

# mise
if (( $+commands[mise] )); then
    eval "$(mise activate zsh)"
fi
