alias ls='ls --color=tty'
alias lsa='ls -lah'
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'

if command -v nvim >/dev/null 2>&1; then
	alias vim='nvim'
	alias vi='nvim'
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

OSFAMILY=$(
    if ! command -v lsb_release >/dev/null; then
        echo 'Unknown'
        exit
    fi
    lsbrelease=$(lsb_release -a 2>/dev/null | awk '/Distributor ID/ {print $NF}')
    if [[ $lsbrelease =~ Manjaro* ]] || [[ $lsbrelease =~ Arch* ]]; then
        echo Arch
    elif [[ $lsbrelease == Ubuntu ]] || [[ $lsbrelease == Debian ]] || [[ $lsbrelease == Raspbian ]]; then
        echo Debian
    else
        echo "not implemented"
    fi
)
export OSFAMILY

reboot-required() {
    if [[ "$OSFAMILY" == "Arch" ]]; then
        diff -q <(sed 's/ x64//g' "$(find /boot/linux* | sort -h | tail -1)") <(uname -r ) >/dev/null || echo 'yes'
    elif [[ "$OSFAMILY" == "Debian" ]]; then
        test -f '/var/run/reboot-required' && echo 'yes'
    fi
}

tmux-select() {
	local sessions
	sessions=$(tmux list-sessions -F '#S')
	if [ "$(echo "$sessions" | wc -l)" -eq 1 ]; then
		tmux at -t "$sessions"
	else
		select sel in $(tmux list-sessions -F '#S'); do break; done && tmux at -t "$sel"
	fi
}
tmux-kill() {
	select sel in $(tmux list-sessions -F '#S'); do break; done && tmux kill-session -t "$sel"
}

ssh-fingerprint() {
	local pubkey="$1"
    shift
	if [ -f "$pubkey" ]; then
		ssh-keygen -lf "$pubkey" "$@"
	else
		ssh-keygen -lf <("$pubkey") "$@"
	fi
}

clr() {
    clear
    echo "Currently logged into $HOST on $TTY, as $USER in directory $PWD."
}
