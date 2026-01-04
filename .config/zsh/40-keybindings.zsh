##############################
# oh-my-zsh plugin replacements
##############################

# sudo plugin replacement: press Esc twice to prepend sudo
sudo-command-line() {
    [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
    if [[ $BUFFER == sudo\ * ]]; then
        LBUFFER="${LBUFFER#sudo }"
    else
        LBUFFER="sudo $LBUFFER"
    fi
}
zle -N sudo-command-line
bindkey '\e\e' sudo-command-line

# safe-paste: bracketed paste mode (built into zsh 5.1+)
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# auto escape URLs
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# Edit the current command line in $VISUAL (or $EDITOR / `vi` if not set)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# vi-mode
bindkey -v
export KEYTIMEOUT=1

# Better searching in vi mode
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

# ssh-agent
# On macOS, the system handles ssh-agent via Keychain
# On Linux, you may want to use keychain or systemd user service
if [[ "$OSTYPE" != darwin* ]] && (( $+commands[ssh-agent] )); then
    if [[ -z "$SSH_AUTH_SOCK" ]]; then
        eval "$(ssh-agent -s)" > /dev/null
    fi
fi

##############################
# completion generators      #
##############################
# Generate completions for tools that support it
# These are cached in $ZSH_CACHE_DIR/completions

_generate_completion() {
    local cmd="$1"
    local comp_file="${ZSH_CACHE_DIR}/completions/_${cmd}"
    
    # Skip if command doesn't exist
    (( $+commands[$cmd] )) || return
    
    # Skip if completion file exists and is newer than the binary
    if [[ -f "$comp_file" ]] && [[ "$comp_file" -nt "${commands[$cmd]}" ]]; then
        return
    fi
    
    case "$cmd" in
        kubectl)    kubectl completion zsh > "$comp_file" 2>/dev/null ;;
        docker)     docker completion zsh > "$comp_file" 2>/dev/null ;;
        gh)         gh completion -s zsh > "$comp_file" 2>/dev/null ;;
        argocd)     argocd completion zsh > "$comp_file" 2>/dev/null ;;
        helm)       helm completion zsh > "$comp_file" 2>/dev/null ;;
        kind)       kind completion zsh > "$comp_file" 2>/dev/null ;;
        poetry)     poetry completions zsh > "$comp_file" 2>/dev/null ;;
        rustup)     rustup completions zsh > "$comp_file" 2>/dev/null ;;
        cargo)      rustup completions zsh cargo > "$comp_file" 2>/dev/null ;;
        uv)         uv generate-shell-completion zsh > "$comp_file" 2>/dev/null ;;
        bun)        bun completions > "$comp_file" 2>/dev/null ;;
        npm)        npm completion > "$comp_file" 2>/dev/null ;;
        deno)       deno completions zsh > "$comp_file" 2>/dev/null ;;
        terraform)  terraform -install-autocomplete 2>/dev/null || true ;;
        tofu)       tofu -install-autocomplete 2>/dev/null || true ;;
    esac
}

# Generate completions for common tools
for cmd in kubectl docker gh argocd helm kind poetry rustup cargo uv bun npm deno; do
    _generate_completion "$cmd"
done

unfunction _generate_completion
