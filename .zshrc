##############################
# zsh config                 #
##############################
# All config lives in ~/.config/zsh and is sourced in order.
# Files are named with numeric prefixes for ordering (like run-parts).
#
# Example structure:
#   01-init.zsh      - XDG, cache dirs, helper functions
#   10-environment.zsh
#   20-completion.zsh
#   30-options.zsh
#   40-keybindings.zsh
#   50-*.zsh         - tool-specific configs
#   80-aliases.zsh
#   90-syntax.zsh    - syntax highlighting (must be near end)
#   99-prompt.zsh    - prompt init (must be last)

ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Source 01-init.zsh first (sets up helpers needed for the rest)
source "${ZDOTDIR}/01-init.zsh"

# Source everything else in order
for file in "${ZDOTDIR}"/*.zsh(N); do
    [[ "${file:t}" == "01-init.zsh" ]] && continue
    source "$file"
done
unset file

# Local machine overrides (not in dotfiles repo)
source_if_exists "${HOME}/.zshrc.local"
