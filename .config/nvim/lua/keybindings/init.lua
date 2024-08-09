local wk = require("which-key")
local opts = { prefix = "" }

vim.g.mapleader = " "

vim.keymap.set("", "<F5>", ":set paste<CR>")

vim.keymap.set("", "<F6>", function()
    vim.opt.relativenumber = not vim.opt.relativenumber
    vim.opt.number = not vim.opt.number
end)

local mappings = {
    { "<F6>", desc = "Toggle line numbers" },
}

-- wrapped lines goes down/up to next row, rather than next line in file
vim.keymap.set("", "j", "gj")
vim.keymap.set("", "k", "gk")

-- visual shifting (does not exit visual mode)
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.keymap.set("v", ".", ":normal .<CR>") -- allow using repeat operator with visual selection

vim.keymap.set("c", "w!!", "w !sudo tee % >/dev/null") -- really write the file

vim.keymap.set("", "<Leader>=", "<C-w>=") -- adjust viewports to all be the same size

vim.keymap.set("", "?", ":WhichKey<CR>") -- show all mappings

vim.keymap.set("", "<Leader>l", ":set list!<cr>") -- enable/disable showing space/newline characters

wk.add(mappings, opts)
