#!/bin/ksh
# shellcheck disable=SC1090 

stty erase  kill  -tabs

if ! [[ $(hostname -s) =~ presto.* ]]; then
    test -r /etc/shmotd && cat /etc/shmotd
fi

has_command() {
    command -v "$1" > /dev/null 2>&1
}

# attempt to launch a better shell than ksh
if has_command zsh && [[ "$SHELL" != *zsh ]]; then
    shell_path="$(command -v zsh)"
elif has_command bash && [[ "$SHELL" != *bash ]]; then
    shell_path="$(command -v bash)"
fi
if [ -n "$shell_path" ]; then
    export SHELL="$shell_path"
    exec "$shell_path"
fi

if [ -d  "$HOME/.local/bin" ]; then
    export PATH="${PATH}:${HOME}/.local/bin"
fi

# tmux funzies
if has_command tmux && [ -z "$TERM_PROGRAM" ]; then
    if [ -z "$TMUX" ]; then # tmux is not running"
        base_session="$(hostname)"
    
        # create new session if not exist
        tmux has-session -t "$base_session" 2>/dev/null || tmux new-session -d -s "$base_session"

        session_cnt=$(tmux ls | wc -l)

        if [ "$session_cnt" -gt 1 ]; then
            echo "Select a tmux session to attacha, C-c for none:"
            select sel in $(tmux ls -F '#S'); do
                break
            done
        else
            sel="$base_session"
        fi

        tmux attach -t "$sel"
    fi
elif has_command screen && [ -z "$TMUX" ] && [ -z "$TERM_PROGRAM" ]; then
    echo "tmux not available, falling back to screen"

    # some of these things dislike normal term settings
    case $(uname) in
        "AIX")
            export TERM=xterm-256color
            ;;
        "HP-UX")
            export TERM=xterm
            ;;
    esac

    if [ -n "$STY" ]; then
        screen -R
    else
        screen -a
    fi
else
    # yes i really want this in single quotes
    # shellcheck disable=SC2016
    echo 'neither screen nor tmux are available or in $PATH'
fi

# set EDITOR to something sane
if [ -z "$EDITOR" ]; then
    if has_command nvim; then
        export EDITOR=nvim
    elif has_command vim; then
        export EDITOR=vim
    elif has_command vi; then
        export EDITOR=vi
    fi
fi

# try and update dotfiles if we can. don't care about re-sourcing, but for next time at least
if has_command yadm; then
    yadm pull
fi

test -r ~/.shell-aliases && source ~/.shell-aliases
has_command setxbmap && setxkbmap -option caps:escape
set -o vi
