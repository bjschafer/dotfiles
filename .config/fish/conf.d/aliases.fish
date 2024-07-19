alias lsa='ls -lah'
alias l='ls -lah'

if test (uname -s) != Darwin 
    alias df='df --human-readable --exclude-type=tmpfs --exclude-type=devtmpfs'
end

if type -q nvim
    alias vim='nvim'
    alias vi='nvim'
    alias view='nvim -R'

    set EDITOR nvim
end

if type -q bat
    alias cat='bat'
end

if type -q batcat
    alias cat='batcat'
end

if type -q eza
    alias ls='eza'
end

if type -q kubecolor
    alias kubectl='kubecolor'
    # compdef kubecolor=kubectl
end

if type -q kubie
    alias kcuc='kubie ctx'
    alias kcn='kubie ns'
else if type -q kubectx
    alias kcuc='kubectx'
    alias kcn='kubens'
end

if type -q stylua
    abbr --add stylua stylua --search-parent-directories
end

if type -q shfmt
    abbr --add shfmt shfmt -i 4 -w
end

# build bash's !! as an abbre
function last_history_item
    echo $history[1]
end
abbr --add !! --position anywhere --function last_history_item

# build bash's !$ as an abbr
function last_history_last_arg
    echo $history[1] | string split --right --max 1 --fields 2 ' '
end
abbr --add '!$' --position anywhere --function last_history_last_arg


# global aliases (expanded anywhere)
abbr --add @oy --position anywhere -- -o yaml
abbr --add @oj --position anywhere -- -o json
