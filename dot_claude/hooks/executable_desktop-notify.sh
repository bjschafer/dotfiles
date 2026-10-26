#!/usr/bin/env bash
# Notification hook: OS-level desktop popup when Claude needs input.
# Cross-platform (macOS/Linux). No-ops gracefully if no notifier is
# available (e.g. headless/SSH session). Never blocks.
set -u

input="$(cat)"
title="$(printf '%s' "$input" | jq -r '.title // "Claude Code"' 2>/dev/null)"
message="$(printf '%s' "$input" | jq -r '.message // "Waiting for your input"' 2>/dev/null)"
[ -z "$title" ] && title="Claude Code"
[ -z "$message" ] && message="Waiting for your input"

case "$(uname -s)" in
    Darwin)
        if command -v terminal-notifier >/dev/null 2>&1; then
            terminal-notifier -title "$title" -message "$message" >/dev/null 2>&1
        elif command -v osascript >/dev/null 2>&1; then
            # Pass via env vars (read with `system attribute`) rather than
            # string-interpolating into the AppleScript source, so message
            # content can never break out of the script.
            CC_TITLE="$title" CC_MSG="$message" osascript \
                -e 'display notification (system attribute "CC_MSG") with title (system attribute "CC_TITLE")' \
                >/dev/null 2>&1
        fi
        ;;
    Linux)
        command -v notify-send >/dev/null 2>&1 && notify-send "$title" "$message" >/dev/null 2>&1
        ;;
esac

exit 0
