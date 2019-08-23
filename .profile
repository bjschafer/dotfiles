#!/bin/ksh
#
#	This is the default standard .profile provided to a user.
#	They are expected to edit it to meet their own needs.

stty erase  kill  -tabs

#[[ -x /epic/bin/csmenu ]] && exec /epic/bin/csmenu
#[[ -x /epic/bin/epicmenu ]] && exec /epic/bin/epicmenu

#exit
if [ -f /usr/bin/zsh ]; then
	export SHELL="/usr/bin/zsh"
	exec /usr/bin/zsh
elif [ -f /bin/bash ]; then
	export SHELL="/bin/bash"
	exec /bin/bash
fi

export PATH="$HOME/.cargo/bin:$PATH"
setxkbmap -option caps:escape
