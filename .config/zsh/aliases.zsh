export COLORTERM=1 # needed for color=tty to be respected, at least on macos
alias ls='ls --color=tty'
alias lsa='ls -lah'
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'

if [[ "$OSTYPE" != darwin* ]]; then
    alias df='df --human-readable --exclude-type tmpfs --exclude-type=devtmpfs'
fi

if command -v nvim >/dev/null 2>&1; then
    alias vim='nvim'
    alias vi='nvim'
    alias view='nvim -R'
elif command -v vim >/dev/null 2>&1; then
    alias vi='vim'
fi

if command -v bat >/dev/null; then
    alias cat='bat'
fi
if command -v batcat >/dev/null; then
    alias cat='batcat'
fi

if command -v eza >/dev/null; then
    alias ls='eza'
fi

if command -v kubecolor >/dev/null; then
    alias kubectl='kubecolor'
    compdef kubecolor=kubectl
fi

if command -v kubectx >/dev/null; then
    alias kcuc='kubectx'
    alias kcn='kubens'
fi
#if command -v kubie >/dev/null; then
#    alias kcuc='kubie ctx'
#fi

if command -v stylua >/dev/null; then
    alias stylua='stylua --search-parent-directories'
fi

if command -v shfmt >/dev/null; then
    alias shfmt='shfmt -i 4 -w'
fi

if command -v xclip >/dev/null; then
    alias xclip='xclip -selection clipboard'
fi

alias purevim='vim -u NONE'

alias brewdump='brew bundle --global --force dump'

######################################
# global aliases (expanded anywhere) #
######################################

alias -g @oy=' -o yaml'
alias -g @oj=' -o json'

# ... etc
alias ..='cd ..'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
