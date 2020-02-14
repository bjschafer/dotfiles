if [ -f "$HOME/.dotfiles/.profile" ]; then
    source "$HOME/.dotfiles/.profile"
    git -C "$HOME/.dotfiles" submodule update --init --recursive
fi
