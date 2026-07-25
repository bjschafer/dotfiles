##############################
# tmux autostart             #
##############################
# Defines tmux_autostart; .zshrc invokes it as the last line, after
# ~/.zshrc.local, so per-machine overrides there are honored.
#
# To disable on a machine (e.g. one running herdr), either:
#   echo 'ZSH_TMUX_AUTOSTART=0' >> ~/.zshrc.local
#   touch "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/no-tmux-autostart"

tmux_autostart() {
    emulate -L zsh

    # Opt-outs, checked first so they're cheap and unconditional.
    [[ "${ZSH_TMUX_AUTOSTART:-1}" == 1 ]] || return 0
    [[ -e "${ZDOTDIR:-$HOME/.config/zsh}/no-tmux-autostart" ]] && return 0

    [[ -o interactive ]] || return 0
    (( $+commands[tmux] )) || return 0

    # Already multiplexed, or nested.
    [[ -n "$TMUX" || -n "$STY" || -n "$ZELLIJ" ]] && return 0

    # Needs a real terminal on both ends.
    [[ -t 0 && -t 1 ]] || return 0

    # Editor- and agent-embedded terminals drive the shell themselves;
    # wrapping them in tmux breaks their control of the pane.
    [[ -n "$INSIDE_EMACS" || -n "$NVIM" || -n "$VIM_TERMINAL" ]] && return 0
    [[ -n "$VSCODE_INJECTION" || "$TERM_PROGRAM" == vscode ]] && return 0
    [[ -n "$CLAUDECODE" || -n "$CLAUDE_CODE_ENTRYPOINT" ]] && return 0

    # Pick a session: prefer an unattached one, then the most recently used,
    # so a second terminal doesn't mirror the view you're already looking at.
    # session_last_attached is empty for a never-attached session, and sort
    # collapses blank runs unless -t is given -- so emit an explicit 0 and
    # pin the separator, keeping sort's field numbering identical to cut's.
    local target
    target=$(tmux list-sessions \
        -F '#{session_attached} #{?session_last_attached,#{session_last_attached},0} #{session_name}' \
        2>/dev/null | sort -t' ' -k1,1n -k2,2nr | head -1 | cut -d' ' -f3-)

    if [[ -n "$target" ]]; then
        exec tmux attach-session -t "=${target}"
    else
        exec tmux new-session -s "${ZSH_TMUX_SESSION:-main}"
    fi
}
