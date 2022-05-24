export COLORTERM=1 # needed for color=tty to be respected, at least on macos
alias ls='ls --color=tty'
alias lsa='ls -lah'
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'

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

if command -v exa >/dev/null; then
    alias ls='exa'
fi

if command -v kubectx >/dev/null; then
    alias kcuc='kubectx'
    alias kcn='kubens'
fi

if command -v shfmt >/dev/null; then
    alias shfmt='shfmt -i 4 -w'
fi

alias purevim='vim -u NONE'

if [[ "$(osfamily)" == darwin ]] && command -v gsed >/dev/null; then
    alias sed='gsed'
fi
alias brewdump='brew bundle --global --force dump'

######################################
# global aliases (expanded anywhere) #
######################################

alias -g @oy=' -o yaml'

# ... etc
alias ..='cd ..'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
