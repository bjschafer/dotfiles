##############################
# zplug initialization       #
##############################
if command -v brew &>/dev/null ; then
    ZPLUG_BASE="$(brew --prefix)/opt/zplug"
else
    ZPLUG_BASE='/usr/share/zplug'
fi
source "$ZPLUG_BASE/init.zsh"

ZSH_CACHE_DIR="${ZPLUG_CACHE_DIR}"

# enable ssh agent forwarding
#zplug "plugins/ssh-agent", from:oh-my-zsh
#zstyle :omz:plugins:ssh-agent agent-forwarding on

###############################
# always-on config            #
###############################
zplug "~/.config/zsh",     from:local,     defer:3   # this should always be loaded last to permit specific overrides
# ~/.zshrc.local is never in version control
zplug "~/",                from:local, use:".zshrc.local"
zplug "plugins/gitfast",   from:oh-my-zsh
zplug "plugins/tmux",      from:oh-my-zsh
zplug "plugins/vi-mode",   from:oh-my-zsh
zplug "zsh-users/zsh-autosuggestions",     defer:2
zplug "zsh-users/zsh-syntax-highlighting", defer:2

zplug "~/.config/zsh/themes", from:local, as:theme

export EDITOR=nvim
export LANG=en_US.UTF-8
export LESS='--tabs=4 --no-init --LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS'

export PATH="${HOME}/.zplug/bin:$PATH"
test -d "${HOME}/.local/bin"  && export PATH="${HOME}/.local/bin:$PATH"
test -d '/usr/local/cats/bin' && export PATH="$PATH:/usr/local/cats/bin"

ZSH_TMUX_AUTOSTART='true'  # auto start when launching shell
ZSH_TMUX_AUTOQUIT='false'  # don't close shell if tmux is closed

##############################
# conditional config         #
##############################
zplug "~/.cargo",               from:local,                                     use:"env"
zplug "plugins/docker",         from:oh-my-zsh, if:"(( $+commands[docker] ))"
zplug "plugins/docker-compose", from:oh-my-zsh, if:"(( $+commands[docker] ))"
zplug "plugins/dotnet",         from:oh-my-zsh, if:"(( $+commands[dotnet] ))"
zplug "junegunn/fzf",                           if:"(( $+commands[fzf] ))",     use:"shell/*.zsh", defer:2
zplug "plugins/golang",         from:oh-my-zsh, if:"(( $+commands[go] ))"
zplug "jonmosco/kube-ps1",                      if:"(( $+commands[kubectl] ))", use:"kube-ps1.sh"
zplug "plugins/kubectl",        from:oh-my-zsh, if:"(( $+commands[kubectl] ))"
zplug "plugins/terraform",      from:oh-my-zsh, if:"(( $+commands[terraform] ))"

# fix username issues
if [[ -z "$USERNAME" ]] ; then
    export PROMPT=$(sed 's/%n/$USER/g' <<< "$PROMPT")
fi

###############################
# commands (!)                #
###############################
zplug "junegunn/fzf-bin",     as:command, from:gh-r, rename-to:fzf

###############################
# install (clone) any plugins #
###############################
if ! zplug check ; then
    zplug check --verbose
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    else
        echo
    fi
fi

########################################
# finally load configured plugins      #
########################################
zplug load
