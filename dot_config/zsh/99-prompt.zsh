##############################
# prompt (must be last)      #
##############################
if (( $+commands[starship] )) && [[ -z ${_STARSHIP_INITIALIZED:-} ]]; then
    source_cached_init starship starship-init.zsh init zsh
    _STARSHIP_INITIALIZED=1
fi

# Starship starts a second process for a right prompt that is empty after
# successful commands. Preserve its useful status labels with shell builtins.
_prompt_status_precmd() {
    local exit_code=$? label
    case "$exit_code" in
        0) RPROMPT=''; return ;;
        1) label=ERROR ;;
        2) label=USAGE ;;
        126) label=NOPERM ;;
        127) label=NOTFOUND ;;
        130) label=INT ;;
        143) label=TERM ;;
        *) label="$exit_code" ;;
    esac
    RPROMPT="%B%F{#e78284}❌ ${label}%f%b"
}
precmd_functions=(_prompt_status_precmd ${precmd_functions:#_prompt_status_precmd})
