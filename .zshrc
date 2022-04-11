##############################
# omz init/config            #
##############################
export ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$HOME/.config/zsh"

zstyle ':omz:update' mode auto      # update automatically without asking

COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="yyyy-mm-dd"

# early source of helper functions
source "${ZSH_CUSTOM}/functions.zsh"

##############################
# always-on config           #
##############################
export LANG=en_US.UTF-8
export EDITOR=nvim
export LESS='--tabs=4 --no-init --LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS'

ZSH_THEME="bjs"
plugins=(sudo ssh-agent vi-mode safe-paste)

# enable ssh agent forwarding
zstyle :omz:plugins:ssh-agent agent-forwarding on

##############################
# OS-based plugins           #
##############################
case "$(osfamily)" in
    darwin)
        FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
        plugins+=(brew macos)
        ;;
    debian)
        plugins+=(ubuntu systemd)
        ;;
    arch)
        plugins+=(archlinux systemd)
        ;;
esac

##############################
# conditional plugins        #
##############################
plugin_if_command fzf fzf
plugin_if_command git gitfast
plugin_if_command go golang
plugin_if_command docker docker docker-compose
plugin_if_command dotnet dotnet
plugin_if_command kubectl kubectl kube-ps1
plugin_if_command rustup rust
plugin_if_command terraform terraform
plugin_if_command tmux tmux

ZSH_TMUX_AUTOSTART='true' # auto start when launching shell
ZSH_TMUX_AUTOQUIT='false' # don't close shell if tmux is closed

##############################
# conditional sources        #
##############################
test -d "${HOME}/.local/bin" && export PATH="${HOME}/.local/bin:$PATH"
test -d "/home/linuxbrew/.linuxbrew/bin" && export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
source_if_exists "${HOME}/.cargo/env"
source_if_exists "${HOME}/.zshrc.local"

# dedupe path
typeset -U path cdpath fpath manpath

source $ZSH/oh-my-zsh.sh
