#!/bin/ksh
#
#	This is the default standard .profile provided to a user.
#	They are expected to edit it to meet their own needs.

stty erase  kill  -tabs

test -f /etc/shmotd && cat /etc/shmotd

has_command() {
    command -v "$1" >/dev/null 2>&1
}

# tmux funzies
if has_command tmux && [ -z "$TMUX" ] && [ -z "$TERM_PROGRAM" ]; then
    base_session="$(hostname)"

    # create new session if not exist
    tmux has-session -t "$base_session" || tmux new-session -d s "$base_session"

    client_cnt=$(tmux list-clients | wc -l)
    if [ "$client_cnt" -ge 1 ]; then
        echo "already a tmux connection with name $base_session. Doing nothing"
        echo "You can attach with tmux -2 attach_session -t $base_session"
    else
        tmux -2 attach-session -t "$base_session"
    fi
elif has_command screen; then
    echo "tmux not available, falling back to screen"
    if [ -z "$STY" ]; then
        screen -R
    else
        screen -a
    fi
else
    echo 'neither screen nor tmux are available or in $PATH'
fi

if [ -f /usr/bin/zsh ]; then
	export SHELL="/usr/bin/zsh"
	exec /usr/bin/zsh
elif [ -f /bin/bash ]; then
	export SHELL="/bin/bash"
	exec /bin/bash
fi

