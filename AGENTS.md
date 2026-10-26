# Dotfiles repo (chezmoi source directory)

This is the chezmoi source for `$HOME`. Files here are not used in place: `chezmoi apply` renders them into `~`. Repo-only files (`README.md`, this file) are listed in `.chezmoiignore` so they are never copied to `~`.

## Layout and naming

- Paths are encoded: `dot_config/zsh/80-aliases.zsh` -> `~/.config/zsh/80-aliases.zsh`. Prefixes set attributes: `private_` (0600/0700), `executable_`, `modify_`, `run_once_`/`run_onchange_`. Use `chezmoi source-path <target>` / `chezmoi target-path <source>` rather than translating by hand.
- `.tmpl` files are Go templates. Machine data: `.email`, `.work`, `.wayland`, `.secrets` (from `.chezmoi.toml.tmpl`), plus `.chezmoi.os`, `.chezmoi.hostname`, etc.
- `.chezmoiignore` is a template of target paths to skip (work-only/home-only files, Claude Code runtime state).
- `.chezmoiremove` lists targets deleted on every machine.
- `.chezmoiexternal.toml` pulls third-party plugins (`fzf-git`, `zsh-you-should-use`, `mo`); don't vendor them.
- `.chezmoiscripts/` holds bootstrap scripts (packages, fisher, chsh, nvim plugins). `run_onchange_` scripts re-run when their rendered content changes, so they embed hashes of the files they depend on.
- `.chezmoitemplates/` holds shared template fragments:
  - `json-merge.sh` is the body of the `modify_` scripts for JSON files an app also writes (`dot_claude/modify_settings.json.tmpl`, `dot_pi/agent/modify_private_settings.json.tmpl`). The managed keys live in `claude-settings.json` / `pi-settings.json`; everything else in those files belongs to the app. The merge must stay byte-identical for unchanged files, or chezmoi reports drift forever.
  - `agents-dotfiles.md` is included into the global Claude and pi instructions.
- `dot_config/zsh/private_11-secrets.zsh.tmpl` exports every key of the OpenBao KV entry `kv/dotfiles/shell-env`; it only renders where `.secrets` is true. Never write secret values into this repo.

## Checking changes

- `chezmoi diff` (or `chezmoi status`) shows what `apply` would change; run it after every edit.
- `chezmoi cat <target>` renders one target; `chezmoi execute-template < file.tmpl` renders a template; add `--override-data '{"work":true}'` (or `chezmoi.os`, etc.) to check other machine types.
- `chezmoi apply --dry-run --verbose` before a real apply. Don't run `chezmoi apply` without `--dry-run` unless asked.
- Shell scripts: `bash -n` / `zsh -n` on the rendered output, not the template.

## History

History before the move to chezmoi is in this repo at the original yadm paths (`.config/...`); tag `yadm-final` is the cutover. Use `git log --follow` to trace a file across it. Never run `yadm`.
