#!/bin/sh
# Desktop notification for a long command that finished in a tmux pane.
# Run by the pane-command-finished hook in tmux.conf, with the pane id, after
# the hook has checked the duration threshold. Needs OSC 133 marks from the
# shell (~/.config/zsh/58-shell-integration.zsh).
#
# Every client attached to the pane's session gets an OSC 777 notification
# written straight to its tty, so it reaches whichever terminal is attached,
# including over ssh. Passthrough from the pane can't do this: with
# allow-passthrough on, tmux only forwards it from visible panes. A client is
# skipped when it is showing this pane and its terminal has focus (tmux's
# "focused" client flag, which needs focus-events on).

pane=$1
tab=$(printf '\t')

info=$(tmux display-message -p -t "$pane" \
    "#{pane_command_status}${tab}#{pane_command_duration}${tab}#{session_name}${tab}#{window_index}${tab}#{window_name}") || exit 0
IFS=$tab read -r status secs session win_idx win_name <<EOF
$info
EOF

if [ "$secs" -ge 3600 ]; then
    dur="$((secs / 3600))h$((secs % 3600 / 60))m"
elif [ "$secs" -ge 60 ]; then
    dur="$((secs / 60))m$((secs % 60))s"
else
    dur="${secs}s"
fi
if [ "$status" = 0 ]; then
    body="✓ finished after $dur"
else
    body="✗ exit $status after $dur"
fi
# ; separates OSC 777 fields; control characters would end the sequence early.
title=$(printf '%s' "$session:$win_idx $win_name" | tr -d ';\000-\037')

tmux list-clients -t "=$session" -F "#{pane_id}${tab}#{m:*focused*,#{client_flags}}${tab}#{client_tty}" |
while IFS=$tab read -r cpane focused tty; do
    [ "$cpane" = "$pane" ] && [ "$focused" = 1 ] && continue
    printf '\033]777;notify;%s;%s\007' "$title" "$body" > "$tty"
    tmux display-message -l -c "$tty" "$title: $body"
done
