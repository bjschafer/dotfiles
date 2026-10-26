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

-- nvim-treesitter on the `main` branch requires the `tree-sitter` CLI binary
-- to compile parsers. Without it, ts.install() fails with cryptic ENOENT errors.
if vim.fn.executable("tree-sitter") == 0 then
    vim.notify(
        "nvim-treesitter: `tree-sitter` CLI not found in PATH. "
            .. "Install it (e.g. `brew install tree-sitter`) to compile parsers.",
        vim.log.levels.ERROR
    )
else
    ts.install(parsers)
end

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
