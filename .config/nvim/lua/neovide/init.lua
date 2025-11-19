if vim.g.neovide then
    vim.g.neovide_input_macos_option_key_is_meta = true
    vim.g.neovide_remember_window_size = true

    -- copy and paste settings
    vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
    vim.keymap.set("v", "<D-c>", '"+y') -- Copy
    vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
    vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
    vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
    vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode
    vim.keymap.set("t", "<D-v>", "<C-R>+") -- Paste terminal mode

    vim.api.nvim_set_current_dir(vim.fs.normalize("~"))

    if vim.fn.hostname() == "swordfish" then
        vim.g.neovide_scale_factor = 0.8
    end
end
