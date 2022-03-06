# When a glob doesn't match anything, pass it through to the command unchanged.
# This is useful for remote globbing, e.g., rsync host:~/foo*.
setopt nonomatch
# Append to the history.
setopt appendhistory
# Use the extended history format, which gives timing info.
setopt extendedhistory
# Append to the history after each command runs, including timing info.
setopt incappendhistorytime
# Do not store duplicate commands.
setopt histignoredups
setopt histsavenodups
# Remove superfluous blanks that sometimes make it into my commands.
setopt histreduceblanks
# Commands beginning with a space are forgotten.
setopt histignorespace
# command correction
setopt correct
# correct based on likely dvorak mistakes, not qwerty
setopt dvorak
