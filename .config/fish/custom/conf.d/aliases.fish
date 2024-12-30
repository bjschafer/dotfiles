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

# A simple version of history expansion - '!!' and '!$'
function histreplace
    switch "$argv[1]"
        case !!
            echo -- $history[1]
            return 0
        case '!$'
            echo -- $history[1] | read -lat tokens
            echo -- $tokens[-1]
            return 0
        case '^*^*'
            set -l kv (string split '^' -- $argv[1])
            or return
            # We replace the first occurrence in each line
            # (collect is to inhibit the final newline)
            string split \n -- $history[1] | string replace -- $kv[2] $kv[3] | string collect
            return 0
    end
    return 1
end
abbr --add !! --function histreplace --position anywhere
abbr --add '!$' --function histreplace --position anywhere
abbr --add histreplace_regex --regex '\^.*\^.*' --function histreplace --position anywhere

# global aliases (expanded anywhere)
abbr --add @oy --position anywhere -- -o yaml
abbr --add @oj --position anywhere -- -o json

abbr --add add. --position anywhere -- add .

function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr --add dotdot --regex '^\.\.+$' --function multicd

# Turn `m ` in command position into `math ""`, with the cursor between the quotes.
abbr m --set-cursor 'math "%"'
