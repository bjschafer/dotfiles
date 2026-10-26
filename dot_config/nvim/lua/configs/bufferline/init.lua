local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
    return
end

bufferline.setup({})

-- BufferLine navigation
vim.keymap.set("n", "<leader>bN", ":BufferLineMoveNext<CR>", { silent = true, desc = "BufferLine: Move next" })
vim.keymap.set("n", "<leader>bP", ":BufferLineMovePrev<CR>", { silent = true, desc = "BufferLine: Move prev" })
