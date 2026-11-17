##############################
# Ghostty native mode        #
##############################
# Widgets behind the ssh/mosh/pwsh bindings in ghostty/native.ghostty. Ghostty
# can't run commands from a keybind, so it types an F13-F17 key instead; the
# widget prompts here and has ghostty-open make the tab or split. That means
# they only work while the focused split is sitting at this shell's prompt.

[[ $TERM_PROGRAM == ghostty && -z ${TMUX-} ]] || return 0
(( $+commands[ghostty-open] )) || return 0

autoload -Uz read-from-minibuffer

# Prompt for a host into REPLY. read-from-minibuffer is meant to put the
# command line back afterwards, but here (vi mode plus the wrapped widgets)
# the typed host was left behind in it, so save and restore it ourselves.
_ghostty_read_host() {
    local lbuf=$LBUFFER rbuf=$RBUFFER
    read-from-minibuffer 'Hostname: '
    local stat=$?
    LBUFFER=$lbuf RBUFFER=$rbuf
    (( stat == 0 )) && [[ -n $REPLY ]]
}

# C-a C-s / C-a C-m: prompt for a host, open a tab named after it running
# ssh/mosh; the tab closes when that exits, like tmux's new-window.
_ghostty_remote_tab() {
    _ghostty_read_host || return
    ghostty-open tab "$REPLY" "$1 ${(q)REPLY}; exit"
}
ghostty-ssh-tab()  { _ghostty_remote_tab 'ssh -A' }
ghostty-mosh-tab() { _ghostty_remote_tab mosh }

# C-a C-p
ghostty-pwsh-tab() { ghostty-open tab pwsh 'pwsh; exit' }

# C-a C-\ / C-a C-_: ssh to this tab's host in a new split. tmux used the
# window name; here it's the tab title C-a C-s set (or C-a , did). Prompts
# when the tab has none.
_ghostty_remote_split() {
    local host=$(ghostty-open title)
    if [[ -z $host ]]; then
        _ghostty_read_host || return
        host=$REPLY
    fi
    [[ -n $host ]] && ghostty-open $1 "ssh -A ${(q)host}; exit"
}
ghostty-ssh-split-right() { _ghostty_remote_split right }
ghostty-ssh-split-down()  { _ghostty_remote_split down }

() {
    local widget key
    for widget key in \
        ghostty-ssh-tab         '\e[25~' \
        ghostty-mosh-tab        '\e[26~' \
        ghostty-pwsh-tab        '\e[28~' \
        ghostty-ssh-split-right '\e[29~' \
        ghostty-ssh-split-down  '\e[31~'
    do
        zle -N $widget
        bindkey -M viins $key $widget
        bindkey -M vicmd $key $widget
    done
}
