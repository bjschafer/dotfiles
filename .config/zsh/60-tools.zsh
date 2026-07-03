##############################
# tool integrations          #
##############################

# direnv
if (( $+commands[direnv] )); then
    eval "$(direnv hook zsh)"
fi

# zoxide
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"

    # `z gitl` matches a base repo and its suffixed siblings (gitlab,
    # gitlab-runners, ...); zoxide picks by frecency and skips $PWD, so it
    # ping-pongs. Collapse to the shortest same-parent sibling, $PWD included.
    z() {
        emulate -L zsh
        if (( $# == 1 )) && [[ $1 != -* && $1 != */* && ! -d $1 ]]; then
            local -a cands=(${(f)"$(zoxide query --list -- $1 2>/dev/null)"})
            if (( $#cands )); then
                local best=${cands[1]} top=${cands[1]:t} parent=${cands[1]:h}
                local blen=${#top} dir base
                for dir in $cands; do
                    base=${dir:t}
                    if [[ ${dir:h} == $parent && ${top[1,${#base}]} == $base ]] && (( ${#base} < blen )); then
                        best=$dir; blen=${#base}
                    fi
                done
                builtin cd -- $best && return
            fi
        fi
        __zoxide_z "$@"
    }
fi

# atuin
if (( $+commands[atuin] )); then
    eval "$(atuin init zsh --disable-up-arrow)"
fi

# mise
if (( $+commands[mise] )); then
    eval "$(mise activate zsh)"
fi
