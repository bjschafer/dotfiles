#!/usr/bin/env bash
# Commit + reconcile + push the shared auto-memory repo.
#
# Wired to PostToolUse (fast propagation), Stop (end of every turn) and
# SessionEnd (final flush). The Stop trigger is the important one: it catches
# memory files written by Bash heredocs/sed, which the PostToolUse
# Write|Edit|MultiEdit matcher never sees.
#
# Reconciles by rebasing onto the remote BEFORE pushing, so a push can no
# longer be rejected non-fast-forward and then silently retried forever.
# Failures are recorded to memory-sync.status / memory-sync.log instead of
# being swallowed. Never blocks or fails the tool call.
set -u

. "$HOME/.claude/hooks/memory-sync-lib.sh" 2>/dev/null || exit 0

mem_repo_ready || exit 0

if mem_in_progress; then
    mem_set_status "rebase-in-progress"
    mem_log "ABORT: repo has an unfinished rebase/merge; not touching it"
    exit 0
fi

# Short wait only: another hook holding the lock is already doing this work.
mem_lock 3 || exit 0
trap 'mem_unlock' EXIT INT TERM

branch="$(mem_branch)"
[ -n "$branch" ] || { mem_log "ABORT: detached HEAD"; mem_set_status "detached-head"; exit 0; }

# --- 1. commit whatever is on disk -------------------------------------
# Repo-wide `add -A` on purpose: scoping to one project's memory dir is what
# strands files written by other sessions on this machine.
committed=0
mem_git add -A >/dev/null 2>&1
if ! mem_git diff --cached --quiet 2>/dev/null; then
    n="$(mem_git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')"
    if mem_git commit -q -m "auto-sync: $(mem_host) ($n file(s))" >/dev/null 2>&1; then
        committed=1
    else
        mem_log "WARN: commit failed"
    fi
fi

# --- 2. decide whether network work is needed ---------------------------
local_head="$(mem_git rev-parse HEAD 2>/dev/null)"
remote_head="$(mem_git rev-parse "refs/remotes/origin/$branch" 2>/dev/null || true)"

need_sync=0
[ "$committed" = "1" ] && need_sync=1
[ "$local_head" != "$remote_head" ] && need_sync=1
if [ "$need_sync" = "0" ]; then
    # Nothing local to send. Still refresh occasionally so a long-running
    # session picks up the other machine's work without a restart.
    stamp_age=999999
    if [ -f "$MEM_FETCH_STAMP" ]; then
        sm="$(mem_mtime "$MEM_FETCH_STAMP")"
        [ -n "$sm" ] && stamp_age=$(( $(mem_now) - sm ))
    fi
    [ "$stamp_age" -ge "$MEM_FETCH_INTERVAL" ] && need_sync=1
fi
[ "$need_sync" = "0" ] && { mem_set_status ""; exit 0; }

# --- 3. fetch + rebase onto the remote ---------------------------------
if ! mem_timeout 25 "${MEM_GIT_CMD[@]}" fetch --quiet origin "$branch" >/dev/null 2>&1; then
    mem_log "WARN: fetch failed (offline?)"
    mem_set_status "offline"
    exit 0
fi
: >"$MEM_FETCH_STAMP" 2>/dev/null

remote_head="$(mem_git rev-parse "refs/remotes/origin/$branch" 2>/dev/null || true)"
if [ -n "$remote_head" ] && [ "$(mem_git rev-parse HEAD)" != "$remote_head" ]; then
    # One rebase covers all three cases: behind-only fast-forwards,
    # ahead-only is a no-op, diverged replays local commits on top.
    if ! mem_git rebase --quiet --autostash "$remote_head" >/dev/null 2>&1; then
        mem_git rebase --abort >/dev/null 2>&1
        files="$(mem_git diff --name-only "$remote_head" HEAD 2>/dev/null | tr '\n' ' ')"
        mem_log "CONFLICT: rebase onto origin/$branch failed; aborted. Overlapping: $files"
        mem_set_status "conflict"
        exit 0
    fi
fi

# --- 4. push (retry once through a fresh rebase) ------------------------
push_ok=0
if mem_timeout 25 "${MEM_GIT_CMD[@]}" push --quiet origin "HEAD:refs/heads/$branch" >/dev/null 2>&1; then
    push_ok=1
else
    if mem_timeout 25 "${MEM_GIT_CMD[@]}" fetch --quiet origin "$branch" >/dev/null 2>&1; then
        rh="$(mem_git rev-parse "refs/remotes/origin/$branch" 2>/dev/null || true)"
        if [ -n "$rh" ] && mem_git rebase --quiet --autostash "$rh" >/dev/null 2>&1; then
            mem_timeout 25 "${MEM_GIT_CMD[@]}" push --quiet origin "HEAD:refs/heads/$branch" >/dev/null 2>&1 && push_ok=1
        else
            mem_git rebase --abort >/dev/null 2>&1
        fi
    fi
fi

if [ "$push_ok" = "1" ]; then
    mem_set_status ""
else
    ahead="$(mem_git rev-list --count "refs/remotes/origin/$branch..HEAD" 2>/dev/null || echo '?')"
    mem_log "PUSH FAILED: $ahead local commit(s) unpushed on branch $branch"
    mem_set_status "unpushed:$ahead"
fi

exit 0
