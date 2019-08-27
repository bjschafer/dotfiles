#!/bin/ksh

stty erase  kill  -tabs

test -f /etc/shmotd && cat /etc/shmotd

has_command() {
    command -v "$1" > /dev/null 2>&1
}

# attempt to launch a better shell than ksh
if has_command zsh && [[ "$SHELL" != *zsh ]]; then
    shell_path="$(which zsh)"
elif has_command bash && [[ "$SHELL" != *bash ]]; then
    shell_path="$(which bash)"
	export SHELL="/bin/bash"
	exec /bin/bash
fi
if [ -n "$shell_path" ]; then
    export SHELL="$shell_path"
    exec "$shell_path"
fi

# tmux funzies
if has_command tmux && [ -z "$TMUX" ] && [ -z "$TERM_PROGRAM" ]; then
    base_session="$(hostname)"

    # create new session if not exist
    tmux has-session -t "$base_session" || tmux new-session -d s "$base_session"

    client_cnt=$(tmux list-clients | wc -l)
    if [ "$client_cnt" -ge 1 ]; then
        client_id=0
        session_name="${base_session}-${client_id}"
        while [ "$(tmux has-session -t "$session_name" 2>& /dev/null; echo $?)" -ne 1 ]; do
            client_id=$((client_id+1))
            session_name="${base_session}-${client_id}"
        done
        tmux new-session -d -t "$base_session" -s "$session_name"
        tmux -2 attach-session -t "$session_name" \; set-option destroy-unattached
    else
        tmux -2 attach-session -t "$base_session"
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

# try and update dotfiles if we can. don't care about re-sourcing, but for next time at least
if has_command yadm; then
    yadm pull
fi

has_command setxbmap && setxkbmap -option caps:escape
