#!/usr/bin/env bash
# PostToolUse hook (Write|Edit|MultiEdit): format the touched file if a
# matching formatter is available. Cross-platform (macOS/Linux). Never
# blocks or fails the tool call — always exits 0.
set -u

input="$(cat)"
file="$(printf '%s' "$input" | jq -r '.tool_response.filePath // .tool_input.file_path // empty' 2>/dev/null)"

if [ -z "$file" ] || [ ! -f "$file" ]; then
    exit 0
fi

has() { command -v "$1" >/dev/null 2>&1; }

# Prefer a project-local prettier (respects the project's pinned version)
# over a global install; --no-install means this is a no-op, not a fetch,
# when the project has no prettier devDependency.
run_prettier() {
    if has npx; then
        npx --no-install prettier --write "$file" >/dev/null 2>&1 && return 0
    fi
    has prettier && prettier --write "$file" >/dev/null 2>&1
}

case "$file" in
    *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|*.css|*.scss|*.md|*.mdx|*.yaml|*.yml|*.html)
        run_prettier
        ;;
    *.py)
        has black && black -q "$file" >/dev/null 2>&1
        ;;
    *.go)
        has gofmt && gofmt -w "$file" >/dev/null 2>&1
        ;;
    *.rs)
        has rustfmt && rustfmt "$file" >/dev/null 2>&1
        ;;
esac

exit 0
