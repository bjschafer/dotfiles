##############################
# history behavior / config  #
##############################
# Append to the history (as they're entered rather than when the shell exits)
setopt incappendhistory
# Use the extended history format, which gives timing info.
setopt extendedhistory
# Do not store (any) duplicate commands.
setopt histignorealldups
setopt histsavenodups
# Remove superfluous blanks that sometimes make it into my commands.
setopt histreduceblanks
# Commands beginning with a space are forgotten.
setopt histignorespace
# better sharing of history between muliple running shells
setopt sharehistory

export HISTFILE=~/.zsh_history
export HISTSIZE=500000
export SAVEHIST=500000

##############################
# misc                       #
##############################

# seriously who uses flow control?
setopt noflowcontrol

# When a glob doesn't match anything, pass it through to the command unchanged.
# This is useful for remote globbing, e.g., rsync host:~/foo*.
setopt nonomatch

# command correction
setopt correct
# correct based on likely dvorak mistakes, not qwerty
setopt dvorak

# if a directory name is given, cd to it instead
setopt autocd
# use the directory stack by default with cd
setopt autopushd
# don't put multiple copies of directory onto pushd stack
setopt pushdignoredups
# don't print directory stack after pushd/popd
setopt pushdsilent

# recognize comments in shell
setopt interactivecomments
