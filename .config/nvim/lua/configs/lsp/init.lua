vim.lsp.config("luals", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc" },
})

vim.lsp.enable("luals")

vim.lsp.inlay_hint.enable()

-- https://github.com/ThePrimeagen/init.lua/blob/249f3b14cc517202c80c6babd0f9ec548351ec71/after/plugin/lsp.lua#L31-L32
-- This is a really good dotfiles sample for configuring LSP in Neovim
-- Refer to this if you need it again in the future
