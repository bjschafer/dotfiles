# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
#ZSH_THEME="eastwood"
ZSH_THEME="bira"

# Uncomment the following line to enable command auto-correction.
#ENABLE_CORRECTION="true"

# display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Which PLUGINS WOULD YOU LIKE To load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(gitfast sudo ssh-agent tmux vi-mode)

# conditional plugins based on system
system_type=$(uname -s)
if [ "$system_type" = "Darwin" ]; then

elif grep -qi ubuntu /etc/issue ; then
    plugins+=(debian)

elif grep -qa manjaro /etc/issue || grep -qa arch /etc/issue ; then
    plugins+=(archlinux)
fi

# enable ssh agent forwarding
zstyle :omz:plugins:ssh-agent agent-forwarding on

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

test -r ~/.shell-aliases   && source ~/.shell-aliases
test -r ~/.env	  	   && source ~/.env
test -r "$HOME/.cargo/env" && source "$HOME/.cargo/env"
test -r "$HOME/.fzf/bin"   && source "$HOME/.fzf/bin"

test -d "${HOME}/.local/bin" && export PATH="${HOME}/.local/bin:$PATH"
test -d '/usr/local/cats/bin' && export PATH="$PATH:/usr/local/cats/bin"

TERMEMULATOR=$(ps -p "$PPID" | tail -n1 | awk '{print $4}') # e.g. yakuake, konsole, etc.

if [[ "$TERMEMULATOR" != "yakuake" ]] && [ -z "$TMUX" ] && [ -z "$TERM_PROGRAM" ]; then
    base_session="$(hostname)"
    # Create a new session if it doesn't exist
    tmux has-session -t "$base_session" || tmux new-session -d -s "$base_session"

    session_cnt=$(tmux ls | wc -l)

    if [ "$session_cnt" -gt 1 ]; then
        echo "Select a tmux session to attach, C-c for none:"
        select sel in $(tmux ls -F '#S'); do
            break
        done
    else
        sel="$base_session"
    fi

    tmux attach -t "$sel"
fi

if (( $+commands[rustup] )) ; then
    plugins+=(rust cargo)
fi

if (( $+commands[kubectl] )) ; then
    plugins+=(kubectl)
    if [ -d "$HOME/.kube/config.d" ] && [ "$(ls "$HOME"/.kube/config.d/* | wc -l)" -gt 0 ]; then
        export KUBECONFIG=$(for f in "$HOME"/.kube/config.d/* ; do echo -n "$f:" ; done)
    fi
    if [ -d "$HOME/development/k8s/clustersconfigs" ] && [ "$(ls "$HOME"/development/k8s/clustersconfigs/config*.yaml | wc -l)" -gt 0 ]; then
        export KUBECONFIG="$KUBECONFIG:$(for f in "$HOME"/development/k8s/clustersconfigs/config*.yaml ; do echo -n "$f:" ; done)"
    fi
fi

if (( $+commands[helm2] )) ; then
    plugins+=(helm)
    if [ -f "$(helm2 home)/cert.pem" ]; then
    export HELM_TLS_ENABLE="true"
    fi
fi

if (( $+commands[helm3] )) ; then
    source <(helm3 completion zsh | sed 's/helm/helm3/g')
fi

if (( $+commands[task] )) ; then
    plugins+=(taskwarrior)
fi

if (( $+commands[docker] )) ; then
    plugins+=(docker)
fi

if (( $+commands[fzf] )) ; then
    plugins+=(fzf)
fi

if (( $+commands[virtualenv] )) ; then
    plugins+=(virtualenv)
fi

if (( $+commands[dnote] )) ; then
    plugins+=(dnote)
fi

if (( $+commands[virtualenvwrapper.sh] )) ; then
    plugins+=(virtualenvwrapper)
    export PROJECT_HOME="$HOME/development/python"
fi

## golang
if [ -n "${GOPATH}" ] ; then
    export PATH="$PATH:${GOPATH}/bin"
elif [ -d "${HOME}/go/bin" ]; then # default gopath.
    export PATH="${HOME}/go/bin:$PATH"
fi
##end golang

export EDITOR=nvim

# load dircolors
test -f "$HOME/.dircolors" && (( $+commands[dircolors] )) && eval "$(dircolors ~/.dircolors)"

# finally load plugins and such
source "$ZSH/oh-my-zsh.sh"

# theme for ssh connections
if [ -n "$SSH_CLIENT" ] && ! [[ "$TERM_CLIENT" == 'PuTTY' ]]; then
    export PROMPT="[%m]$PROMPT"
fi

#if (( $+commands[ssh-agent] )) && [ ! -S ~/.ssh/ssh_auth_sock ]; then
#  eval `ssh-agent`
#  ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
#fi
#export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
#ssh-add -l > /dev/null || ssh-add
