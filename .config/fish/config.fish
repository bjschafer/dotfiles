set PATH $HOME/.local/bin $PATH

if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source

    if type -q fzf
        fzf --fish | source
    end

    if type -q atuin
        atuin init fish --disable-up-arrow | source
    end

    if type -q zoxide
        zoxide init fish | source
    end
end