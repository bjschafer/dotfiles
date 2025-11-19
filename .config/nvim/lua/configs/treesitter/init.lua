local status_ok, treesitter_configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
    return
end

treesitter_configs.setup({
    -- a list of parser names, or "all"
    ensure_installed = {},

    -- sync = synchronous
    sync_install = false,

    -- auto install missing parsers when entering buffer
    -- recommend setting to false if you don't have `tree-sitter` CLI installed
    auto_install = false,

    -- if you need to change the install directory of the parsers (see -> Advanced Setup)
    -- parser_install_dir = "/some/path/to/store", -- remember to run vim.opt.runtimepath:append("/some/path/to/store")!

    highlight = {
        enable = true, -- false disables the entire extension

        -- setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on syntax being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
})
