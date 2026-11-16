##############################
# misc shell functions       #
##############################

reboot-required() {
    local OSFAMILY=$(osfamily)
    if [[ "$OSFAMILY" == "arch" ]]; then
        # Compare the running kernel to the installed version of the *same* package
        # (linux, linux-zen, linux-lts, ...), so other installed kernels don't matter.
        local running=$(uname -r) pkg installed
        pkg=$(< "/usr/lib/modules/$running/pkgbase" 2>/dev/null)
        if [[ -z "$pkg" ]]; then
            # Modules dir already gone (package upgraded): infer from the version suffix.
            case "$running" in
                *-arch*)     pkg=linux ;;
                *-zen)       pkg=linux-zen ;;
                *-lts)       pkg=linux-lts ;;
                *-hardened)  pkg=linux-hardened ;;
                *-rt)        pkg=linux-rt ;;
                *)           pkg=$(pacman -Qqo "/usr/lib/modules/$running" 2>/dev/null) ;;
            esac
        fi
        installed=$(pacman -Qlq "$pkg" 2>/dev/null | sed -n 's#^/usr/lib/modules/\([^/]*\)/$#\1#p' | head -1)
        if [[ -z "$installed" ]]; then
            echo "reboot-required: can't determine installed version of '$pkg'" >&2
            return 2
        fi
        if [[ "$installed" != "$running" ]]; then
            echo "$pkg: running $running, installed $installed" >&2
            echo 'yes'
        fi
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

yadm() {
    echo 'This machine no longer uses yadm to manage dotfiles, it uses chezmoi.' >&2
}

# chezmoi has no command aliases; give it git's `st`.
chezmoi() {
    if [[ "$1" == st ]]; then
        shift
        command chezmoi status "$@"
    else
        command chezmoi "$@"
    fi
}
