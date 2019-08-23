#!/bin/ksh
#
#	This is the default standard .profile provided to a user.
#	They are expected to edit it to meet their own needs.

stty erase  kill  -tabs

test -f /etc/shmotd && cat /etc/shmotd

has_command() {
    command -v "$1" >/dev/null 2>&1
}

if has_command zsh; then
    shell_path="$(command zsh)"
elif has_command bash; then
    shell_path="$(command bash)"
	export SHELL="/bin/bash"
	exec /bin/bash
fi
if [ -z "$shell_path" ]; then
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
    if [ -z "$STY" ]; then
        screen -R
    else
        screen -a
    fi
else
    echo 'neither screen nor tmux are available or in $PATH'
fi


setxkbmap -option caps:escape
