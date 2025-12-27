##############################
# prompt (must be last)      #
##############################
if (( $+commands[starship] )); then
    eval "$(starship init zsh)"
fi
