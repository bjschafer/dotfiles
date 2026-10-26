#!/usr/bin/env bash
# PostToolUse hook (Write|Edit|MultiEdit): fast-path propagation when Claude
# writes inside the synced memory repo. Filters on the written path so an
# unrelated write in any other project stays cheap, then hands off to the one
# real sync path in memory-sync.sh.
#
# This matcher cannot see files written via Bash (heredoc/sed/tee) -- the Stop
# hook is what guarantees those still get committed.
set -u

MEMORY_REPO="${MEMORY_REPO:-$HOME/.local/share/claude-memory}"

input="$(cat)"
file="$(printf '%s' "$input" | jq -r '.tool_response.filePath // .tool_input.file_path // empty' 2>/dev/null)"

case "$file" in
    "$MEMORY_REPO"/*) ;;
    *) exit 0 ;;
esac

bash "$HOME/.claude/hooks/memory-sync.sh" </dev/null >/dev/null 2>&1

exit 0
