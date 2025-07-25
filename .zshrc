##############################
# omz init/config            #
##############################
if [[ -d "$HOME/.local/share/oh-my-zsh" ]]; then
    export ZSH="$HOME/.local/share/oh-my-zsh"
else
    export ZSH="$HOME/.oh-my-zsh"
fi
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
TIMEFMT=$'real\t%E\nuser\t%U\nsys\t%S'

ZSH_THEME='bjs'
plugins=(sudo ssh-agent vi-mode safe-paste)

##############################
# OS-based plugins           #
##############################
case "$(osfamily)" in
    darwin)
        eval "$(/opt/homebrew/bin/brew shellenv)"
        FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
        plugins+=(brew macos gnu-utils)
        ;;
    debian)
        plugins+=(debian systemd)
        ;;
    arch)
        plugins+=(archlinux systemd)
        ;;
esac

##############################
# conditional plugins        #
##############################
plugin_if_command argocd    argocd
plugin_if_command bun       bun
plugin_if_command code      vscode
plugin_if_command direnv    direnv
plugin_if_command docker    docker docker-compose
plugin_if_command dotnet    dotnet
plugin_if_command fzf       fzf
plugin_if_command git       gitfast
plugin_if_command go        golang
plugin_if_command kubectl   kubectl kube-ps1
plugin_if_command npm       npm
plugin_if_command poetry    poetry
plugin_if_command psql      postgres
plugin_if_command rustup    rust
plugin_if_command terraform terraform
plugin_if_command tmux      tmux
plugin_if_command uv        uv
plugin_if_command zoxide    zoxide

ZSH_TMUX_AUTOSTART='true' # auto start when launching shell
ZSH_TMUX_AUTOQUIT='false' # don't close terminal if tmux is closed

##############################
# conditional sources        #
##############################
test -d "${HOME}/.local/bin" && export PATH="${HOME}/.local/bin:$PATH"
test -d "${XDG_DATA_HOME}/go/bin" && export PATH="$PATH:${XDG_DATA_HOME}/go/bin"
test -d "${XDG_DATA_HOME}/dotnet/.dotnet/tools" && export PATH="$PATH:${XDG_DATA_HOME}/dotnet/.dotnet/tools"
source_if_exists "${XDG_DATA_HOME}/cargo/env"
source_if_exists "${HOME}/.zshrc.local"

# dedupe path
typeset -U path cdpath fpath manpath

source "$ZSH/oh-my-zsh.sh"

if (( $+commands[starship] )); then
    eval "$(starship init zsh)"
fi

if (( $+commands[atuin] )); then
    eval "$(atuin init zsh --disable-up-arrow)"
fi
