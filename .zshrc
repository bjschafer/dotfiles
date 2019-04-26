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
# ENABLE_CORRECTION="true"

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
plugins=(gitfast sudo ssh-agent tmux kubectl helm cargo rust vi-mode docker taskwarrior)

# conditional plugins based on system
if [ "$system_type" = "Darwin" ]; then
	plugins+=(brew)

elif grep -qi ubuntu /etc/issue ; then
	plugins+=(debian)

elif grep -qa manjaro /etc/issue || grep -qa arch /etc/issue ; then
    plugins+=(archlinux)
fi

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
test -r ~/.shell-aliases && source ~/.shell-aliases
test -r ~/.env	  	 && source ~/.env

grep -qi Microsoft /proc/sys/kernel/osrelease 2> /dev/null
IS_WSL=$?

if [ -z "$TMUX" ] && [ -z "$TERM_PROGRAM" ]; then
# if [ -z "$TMUX" ] && [ -z "$DISPLAY" ] && [ -z "$TERM_PROGRAM" ]; then
    base_session="default"
    # Create a new session if it doesn't exist
    tmux has-session -t $base_session || tmux new-session -d -s $base_session

    client_cnt=$(tmux list-clients | wc -l)
    # Are there any clients connected already?
    if [ $client_cnt -ge 1 ]; then
        client_id=0
        session_name=$base_session"-"$client_id
        while [ $(tmux has-session -t $session_name 2>& /dev/null; echo $?) -ne 1 ]; do
            client_id=$((client_id+1))
            session_name=$base_session"-"$client_id
        done
        tmux new-session -d -t $base_session -s $session_name
        tmux -2 attach-session -t $session_name \; set-option destroy-unattached
    else
        tmux -2 attach-session -t $base_session
    fi
fi

# if [[ $IS_WSL == 0 ]]; then
# 	export DISPLAY=127.0.0.1:0.0
# 	dbus-launch --exit-with-x11
# fi

if [ $commands[kubectl] ]; then
    source <(kubectl completion zsh)
    plugins+=(kubectl)
#    plugins+=(kube-ps1) # kubeon/kubeoff 
fi

if [ $commands[helm] ]; then
  source <(helm completion zsh)
fi

function kube-ns() {
	context=$(kubectl config current-context)
	kubectl config set-context $context --namespace="$1"
}

export PATH="${HOME}/.local/bin:$PATH"
test -d "${HOME}/go/bin" && export PATH="${HOME}/go/bin:$PATH"
cd ~
