##############################
# misc shell functions       #
##############################

reboot-required() {
    local OSFAMILY=$(osfamily)
    if [[ "$OSFAMILY" == "arch" ]]; then
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

BRANCH_BASE='bschafer'

wt-add() {
    local jira="$1"
    local reponame="$(git config --local --get remote.origin.url | awk -F'(\\/|\\.)' '{ print $(NF-1) }')"

    if ! [[ -d '.git' ]]; then
        echo 'not currently in a repo'
        return
    fi

    if [[ "$jira" =~ ^[0-9]+$ ]]; then
        jira="K8S-${jira}"
    fi

    local worktree_path="../${jira}"
    local branch="${BRANCH_BASE}/${jira}"

    if [[ -d "$worktree_path" ]]; then
        echo "worktree already exists for ${jira}"
        return
    fi

    git worktree add "$worktree_path" -b "$branch"

    if [[ "$reponame" == 'service-automation-ops-gen' ]]; then
        pushd "$worktree_path" >/dev/null || return
        ln -s ../master/node_modules node_modules
        popd >/dev/null || return
    fi
}
