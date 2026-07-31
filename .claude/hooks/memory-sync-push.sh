#!/usr/bin/env bash
# PostToolUse hook (Write|Edit|MultiEdit): when Claude writes inside the
# synced auto-memory repo, commit and push so other machines can pull it.
# Only acts on writes under $MEMORY_REPO; no-ops for every other file.
# Never blocks or fails the tool call.
set -u

MEMORY_REPO="$HOME/.local/share/claude-memory"

input="$(cat)"
file="$(printf '%s' "$input" | jq -r '.tool_response.filePath // .tool_input.file_path // empty' 2>/dev/null)"

case "$file" in
    "$MEMORY_REPO"/*) ;;
    *) exit 0 ;;
esac

git -C "$MEMORY_REPO" add -A >/dev/null 2>&1
git -C "$MEMORY_REPO" commit -m "auto-sync" >/dev/null 2>&1
timeout 10 git -C "$MEMORY_REPO" push --quiet >/dev/null 2>&1

exit 0
