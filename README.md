# bjschafer's dotfiles

This repo is how I manage my dotfiles -- config for my shell environment.

While this is for my own use, you're welcome to look at, be inspired by, or straight up steal anything
that catches your eye -- at your own risk.

I regularly run macOS, Debian stable, and Arch, so my dotfiles are mostly portable across those systems.

## Possibly interesting things

- Shell aliases now live in `.config/zsh/aliases.zsh`.
- Most other custom profile garbage lives alongside it in `.config/zsh`.
- Nested `tmux` on remote host (just hit <kbd>F12</kbd>!)
- Local overrides for things like ZSH `.zshrc.local` and Git `.gitconfig.local`.
- I try to only load/install things where applicable, to keep things lighter weight.

## Notes

- I manage the dotfiles via [yadm](https://yadm.io/), which is mostly a lightweight Git wrapper.
- I use neovim as my primary editor, and [`lazy.nvim`](https://github.com/folke/lazy.nvim) as the plugin manager therein.
