system_type=$(uname -s)
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="eastwood"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
#ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which PLUGINS WOULD YOU LIKE To load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(gitfast sudo ssh-agent tmux vi-mode)

# conditional plugins based on system
if [ "$system_type" = "Darwin" ]; then
	plugins+=(brew)

elif grep -qi ubuntu /etc/issue ; then
	plugins+=(debian)

elif grep -qa manjaro /etc/issue || grep -qa arch /etc/issue ; then
    plugins+=(archlinux)
fi

# enable ssh agent forwarding
zstyle :omz:plugins:ssh-agent agent-forwarding on

# theme for ssh connections
if [ -n "$SSH_CLIENT" ]; then
    export PROMPT="[%m]$PROMPT"
fi

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

test -r ~/.shell-aliases   && source ~/.shell-aliases
test -r ~/.env	  	   && source ~/.env
test -r "$HOME/.cargo/env" && source "$HOME/.cargo/env"

#grep -qi Microsoft /proc/sys/kernel/osrelease 2> /dev/null
#IS_WSL=$?
#if [ "$IS_WSL" -eq 0 ] && [ -z "${DISPLAY+x}" ] ; then
#    # for wsl2 X11
#    export DISPLAY="$(ip route show | grep via | awk '{ print  }'):0"
#fi

export PATH="${HOME}/.local/bin:$PATH"

TERMEMULATOR=$(ps -p "$PPID" | tail -n1 | awk '{print $4}') # e.g. yakuake, konsole, etc.

if [[ "$TERMEMULATOR" != "yakuake" ]] && [ -z "$TMUX" ] && [ -z "$TERM_PROGRAM" ]; then
# if [ -z "$TMUX" ] && [ -z "$DISPLAY" ] && [ -z "$TERM_PROGRAM" ]; then
    base_session="$(hostname)"
    # Create a new session if it doesn't exist
    tmux has-session -t "$base_session" || tmux new-session -d -s "$base_session"

    client_cnt=$(tmux list-clients | wc -l)
    # Are there any clients connected already?
    if [ "$client_cnt" -ge 1 ]; then
    client_id=0
    session_name=$base_session"-"$client_id
    while [ "$(tmux has-session -t "$session_name" 2>& /dev/null; echo $?)" -ne 1 ]; do
    client_id=$((client_id+1))
    session_name=$base_session"-"$client_id
    done
    tmux new-session -d -t "$base_session" -s "$session_name"
    tmux -2 attach-session -t "$session_name" \; set-option destroy-unattached
    else
    tmux -2 attach-session -t "$base_session"
    fi
fi

# if [[ $IS_WSL == 0 ]]; then
# 	export DISPLAY=127.0.0.1:0.0
# 	dbus-launch --exit-with-x11
# fi

if (( $+commands[rustup] )) ; then
    plugins+=(rust cargo)
fi

if (( $+commands[kubectl] )) ; then
    plugins+=(kubectl)
    if [ -d "$HOME/.kube/config.d" ] && [ "$(ls "$HOME"/.kube/config.d/* | wc -l)" -gt 0 ]; then
    export KUBECONFIG=$(for f in "$HOME"/.kube/config.d/* ; do echo -n "$f:" ; done)
    fi
fi

if (( $+commands[helm] )) ; then
    plugins+=(helm)
    if [ -f "$(helm home)/cert.pem" ]; then
    export HELM_TLS_ENABLE="true"
    fi
fi

if (( $+commands[task] )) ; then
    plugins+=(taskwarrior)
fi

if (( $+commands[docker] )) ; then
    plugins+=(docker)
fi

test -d "${HOME}/go/bin" && export PATH="${HOME}/go/bin:$PATH"
cd ~ || return
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export EDITOR=nvim

# load dircolors
test -f "$HOME/.dircolors" && eval "$(dircolors ~/.dircolors)"

# finally load plugins and such
source "$ZSH/oh-my-zsh.sh"
