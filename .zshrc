##############################
# homebrew is frustrating    #
##############################
if [[ -d /opt/homebrew/ ]]; then # arm64
    HOMEBREW_BASE='/opt/homebrew'
    eval "$(${HOMEBREW_BASE}/bin/brew shellenv)"
    unset HOMEBREW_BASE
elif [[ -d /usr/local/homebrew ]]; then # amd64
    HOMEBREW_BASE='/usr/local'
    eval "$(${HOMEBREW_BASE}/bin/brew shellenv)"
    unset HOMEBREW_BASE
fi

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
zplug "~/.config/zsh", \
    from:local, \
    defer:3        # this should always be loaded last to permit specific overrides

zplug "~/", \
    from:local, \
    use:".zshrc.local" # ~/.zshrc.local is never in version control

zplug "plugins/gitfast", from:oh-my-zsh
zplug "plugins/tmux",    from:oh-my-zsh
zplug "plugins/vi-mode", from:oh-my-zsh

# shows alias expansions; useful for screensharing
export PRINT_ALIAS_IGNORE_REDEFINED_COMMANDS=true
zplug "brymck/print-alias"

zplug "zsh-users/zsh-autosuggestions", \
    defer:1

zplug "zsh-users/zsh-syntax-highlighting", \
    defer:1

export EDITOR=nvim
export LANG=en_US.UTF-8
export LESS='--tabs=4 --no-init --LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS'

export PATH="${HOME}/.zplug/bin:$PATH"
test -d "${HOME}/.local/bin"  && export PATH="${HOME}/.local/bin:$PATH"

ZSH_TMUX_AUTOSTART='true'  # auto start when launching shell
ZSH_TMUX_AUTOQUIT='false'  # don't close shell if tmux is closed

##############################
# theming/look and feel      #
##############################

zplug "~/.config/zsh/themes", \
    from:local, \
    as:theme

# fix username issues
if [[ -z "$USERNAME" ]] ; then
    export PROMPT="${PROMPT//%n/$USER/}"
fi

##############################
# conditional config         #
##############################
zplug "~/.cargo",               from:local,                                     use:"env"
zplug "plugins/docker",         from:oh-my-zsh, if:"(( $+commands[docker] ))"
zplug "plugins/docker-compose", from:oh-my-zsh, if:"(( $+commands[docker] ))"
zplug "plugins/dotnet",         from:oh-my-zsh, if:"(( $+commands[dotnet] ))"
zplug "junegunn/fzf",                           if:"(( $+commands[fzf] ))",     use:"shell/*.zsh", defer:2
zplug "plugins/golang",         from:oh-my-zsh, if:"(( $+commands[go] ))"
zplug "reegnz/jq-zsh-plugin",                   if:"(( $+commands[jq] ))"
zplug "jonmosco/kube-ps1",                      if:"(( $+commands[kubectl] ))", use:"kube-ps1.sh"
zplug "plugins/kubectl",        from:oh-my-zsh, if:"(( $+commands[kubectl] ))"
zplug "plugins/terraform",      from:oh-my-zsh, if:"(( $+commands[terraform] ))"


###############################
# commands (!)                #
###############################
#zplug "junegunn/fzf",     as:command, from:gh-r, rename-to:fzf

########################################
# finally, load configured plugins     #
########################################

# dedupe path
typeset -U path cdpath fpath manpath

zplug load
