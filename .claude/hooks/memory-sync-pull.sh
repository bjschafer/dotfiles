#!/usr/bin/env bash
# SessionStart hook: if the current directory is a git repo not yet
# registered for cross-machine auto-memory sync, register it (via
# claude-memory-init), then pull the latest memory from other machines
# before memory files are loaded into context. Never blocks session
# startup beyond a short timeout; all failures (offline, not a git repo,
# already configured, etc.) are silent.
set -u

MEMORY_REPO="$HOME/.local/share/claude-memory"
INIT_SCRIPT="$HOME/.local/bin/claude-memory-init"

auto_register() {
    command -v jq >/dev/null 2>&1 || return 0
    [ -x "$INIT_SCRIPT" ] || return 0

    local repo_root settings_file
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 0

    # Never register the sync repo against itself.
    [ "$repo_root" = "$MEMORY_REPO" ] && return 0

    settings_file="$repo_root/.claude/settings.local.json"

    # Already configured (or explicitly set) -- never overwrite.
    if [ -f "$settings_file" ] && jq -e 'has("autoMemoryDirectory")' "$settings_file" >/dev/null 2>&1; then
        return 0
    fi

    timeout 10 "$INIT_SCRIPT" "$repo_root" >/dev/null 2>&1
}

if [ -d "$MEMORY_REPO/.git" ]; then
    auto_register
    timeout 8 git -C "$MEMORY_REPO" pull --quiet >/dev/null 2>&1
fi

exit 0
