vim.opt.list = true
vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")

require("ibl").setup({
    exclude = {
        filetypes = { "json", "markdown" },
        buftypes = { "markdown" },
    },
})
