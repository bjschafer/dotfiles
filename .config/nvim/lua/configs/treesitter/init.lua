local status_ok, ts = pcall(require, "nvim-treesitter")
if not status_ok then
    return
end

local parsers = {
    "bash",
    "go",
    "gomod",
    "hcl",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "rust",
    "terraform",
    "toml",
    "typescript",
    "vim",
    "vimdoc",
    "yaml",
    "zig",
}

ts.setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
})

ts.install(parsers)

-- Filetypes that should trigger treesitter highlighting. Most match parser
-- names 1:1; markdown covers both `markdown` and `markdown_inline` injections.
local highlight_filetypes = {
    "bash",
    "go",
    "gomod",
    "hcl",
    "javascript",
    "json",
    "lua",
    "markdown",
    "python",
    "rust",
    "terraform",
    "toml",
    "typescript",
    "vim",
    "yaml",
    "zig",
}

vim.api.nvim_create_autocmd("FileType", {
    pattern = highlight_filetypes,
    callback = function()
        pcall(vim.treesitter.start)
    end,
})
