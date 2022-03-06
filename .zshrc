if command -v brew &>/dev/null ; then
    ZPLUG_BASE="$(brew --prefix)/opt/zplug)"
else
    ZPLUG_BASE='/usr/share/zplug'
fi
source "$ZPLUG_BASE/init.zsh"

zplug "~/.config/zsh/themes", from:local, as:theme

# enable ssh agent forwarding
#zplug "plugins/ssh-agent", from:oh-my-zsh
#zstyle :omz:plugins:ssh-agent agent-forwarding on

# always-on config
zplug "~/.config/zsh",     from:local
zplug "~/",                from:local, use:".zshrc.local"
zplug "plugins/gitfast",   from:oh-my-zsh
zplug "plugins/tmux",      from:oh-my-zsh
zplug "plugins/vi-mode",   from:oh-my-zsh
zplug "zsh-users/zsh-autosuggestions",     defer:2
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# conditional config
zplug "plugins/docker",         from:oh-my-zsh, if:"(( $+commands[docker] ))"
zplug "plugins/docker-compose", from:oh-my-zsh, if:"(( $+commands[docker] ))"
zplug "plugins/dotnet",         from:oh-my-zsh, if:"(( $+commands[dotnet] ))"
zplug "plugins/golang",         from:oh-my-zsh, if:"(( $+commands[go] ))"
zplug "jonmosco/kube-ps1",                      if:"(( $+commands[kubectl] ))", use:"kube-ps1.sh"
zplug "plugins/kubectl",        from:oh-my-zsh, if:"(( $+commands[kubectl] ))"
zplug "plugins/terraform",      from:oh-my-zsh, if:"(( $+commands[terraform] ))"

zplug "~/.cargo",               from:local,     use:"env"

export EDITOR=nvim
export LANG=en_US.UTF-8

# local settings
if [[ -f "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi

test -d "${HOME}/.local/bin"  && export PATH="${HOME}/.local/bin:$PATH"
test -d '/usr/local/cats/bin' && export PATH="$PATH:/usr/local/cats/bin"

ZSH_TMUX_AUTOSTART='true'  # auto start when launching shell
ZSH_TMUX_AUTOQUIT='false'  # don't close shell if tmux is closed

if (( $+commands[kubectl] )) ; then
    if [[ -d "$HOME/.kube/config.d" ]] && [[ -n $(find "$HOME/.kube/config.d" -not -empty) ]] ; then
        export KUBECONFIG=$(for f in "$HOME"/.kube/config.d/* ; do echo -n "$f:" ; done)
    fi
    if [[ -d "$HOME/.krew/bin" ]]; then export PATH="$PATH:$HOME/.krew/bin" ; fi

    KUBE_PS1_PREFIX='['
    KUBE_PS1_SUFFIX=']'
    KUBE_PS1_SYMBOL_ENABLE=false

    function get_cluster_short() {
        cut -d'@' -f1 <<< "$1"
    }

    KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
else
    function kube_ps1() { }
fi

if (( $+commands[fzf] )) ; then
    test -r "$HOME/.fzf/bin" && source "$HOME/.fzf/bin"
    if (( $+commands[rg] )); then
        export FZF_DEFAULT_COMMAND='rg -l --hidden -g "" --ignore .git/'
    elif (( $+commands[ag] )) ; then
        export FZF_DEFAULT_COMMAND='ag -l --hidden -g "" --ignore .git/'
    fi
fi

if (( $+commands[rg] )) ; then
    export RIPGREP_CONFIG_PATH="$HOME/.config/rg/rg.conf"
fi

# load dircolors
#test -f "$HOME/.dircolors" && (( $+commands[dircolors] )) && eval "$(dircolors ~/.dircolors)"

# fix username issues
if [[ -z "$USERNAME" ]] ; then
    export PROMPT=$(sed 's/%n/$USER/g' <<< "$PROMPT")
fi

# Install plugins if there are plugins that have not been installed
if ! zplug check ; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    else
        echo
    fi
fi
# finally load plugins and such
zplug load
