-- these are not part of IBL itself, they just make sense here
--vim.opt.list = true
vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")

local status_ok, ibl = pcall(require, "ibl")
if not status_ok then
    return
end

ibl.setup({
    exclude = {
        filetypes = { "json", "markdown" },
        buftypes = { "markdown" },
    },
})
