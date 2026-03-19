##############################
# prompt (must be last)      #
##############################
if (( $+commands[starship] )) && [[ -z ${_STARSHIP_INITIALIZED:-} ]]; then
    eval "$(starship init zsh)"
    _STARSHIP_INITIALIZED=1
fi
