if [ -f "$HOME/.dotfiles/.profile" ]; then
    source "$HOME/.dotfiles/.profile"
    git -C "$HOME/.dotfiles" submodule update --init --recursive
    if [ -n "$TMUX" ]; then
        tmux source "$HOME/.tmux.conf"
        "$HOME/.tmux/plugins/tpm/bin/install_plugins"
    fi
fi
