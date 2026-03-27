-- ensure installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- configure plugins
require("lazy").setup({
    { "mbbill/undotree", cmd = "UndotreeToggle" },

    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

    { "tpope/vim-fugitive", cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit" } },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            on_attach = function(bufnr)
                local gs = require("gitsigns")
                local opts = { buffer = bufnr }

                vim.keymap.set("n", "]c", function()
                    if vim.wo.diff then return "]c" end
                    vim.schedule(function() gs.nav_hunk("next") end)
                    return "<Ignore>"
                end, vim.tbl_extend("force", opts, { expr = true }))

                vim.keymap.set("n", "[c", function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(function() gs.nav_hunk("prev") end)
                    return "<Ignore>"
                end, vim.tbl_extend("force", opts, { expr = true }))

                vim.keymap.set("n", "<leader>gs", gs.stage_hunk, opts)
                vim.keymap.set("n", "<leader>gr", gs.reset_hunk, opts)
                vim.keymap.set("n", "<leader>gp", gs.preview_hunk, opts)
                vim.keymap.set("n", "<leader>gb", function() gs.blame_line({ full = true }) end, opts)
                vim.keymap.set("n", "<leader>gd", gs.diffthis, opts)
            end,
        },
    },
    { "vmware-archive/salt-vim", ft = "sls" },
    { "Glench/vim-jinja2-syntax", ft = { "jinja", "jinja2", "htmljinja" } },

    {
        "ray-x/go.nvim",
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup()
        end,
        event = { "CmdlineEnter" },
        ft = { "go", "gomod" },
        build = ":lua require('go.install').update_all_sync()",
    },

    "neovim/nvim-lspconfig",
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    },

    { "dhruvasagar/vim-table-mode", ft = "markdown", cmd = "TableModeToggle" },

    -- lsp
    {
        "mason-org/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonUpdate" },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "bash-language-server",
                    "gopls",
                    "lua-language-server",
                    "rust-analyzer",
                    "terraform-ls",
                    "vtsls",
                    "yaml-language-server",
                    "zls",
                },
            })
        end,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },
    },

    {
        "saghen/blink.cmp",
        version = "1.*",
        event = "InsertEnter",
        opts = {
            keymap = { preset = "super-tab" },
            appearance = { nerd_font_variant = "mono" },
            completion = {
                documentation = { auto_show = true },
                ghost_text = { enabled = true },
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            fuzzy = { implementation = "prefer_rust" },
        },
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        opts = {},
    },

    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
        ft = { "markdown" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    },

    {
        "iamcco/markdown-preview.nvim",
        ft = "markdown",
        cmd = { "MarkdownPreview", "MarkdownPreviewToggle" },
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
    },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons", opt = true },
    },
    {
        "akinsho/bufferline.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = "nvim-tree/nvim-web-devicons",
    },
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        keys = {
            { "<leader>ff" },
            { "<leader>fg" },
            { "<leader>fb" },
            { "<leader>fh" },
            { "<leader>fk" },
            { "<leader>fo" },
            { "<leader>fs" },
        },
        dependencies = { { "nvim-lua/plenary.nvim" } },
    },

    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        keys = {
            { "<leader>ha" },
            { "<leader>hh" },
            { "<leader>h1" },
            { "<leader>h2" },
            { "<leader>h3" },
            { "<leader>h4" },
            { "<leader>hp" },
            { "<leader>hn" },
        },
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-telescope/telescope.nvim" },
        },
    },
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        cmd = "ConformInfo",
        opts = {},
    },

    {
        "folke/which-key.nvim",
        dependencies = { { "echasnovski/mini.icons" } },
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
    },

    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        cmd = "Neotree",
        keys = {
            { "<leader>ee" },
            { "<leader>eg" },
            { "<leader>eb" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
            "3rd/image.nvim",
        },
    },

    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {
            labels = "aoeuidhtnspyfgcrlqjkxbmwvz",
        },

        -- stylua: ignore
        keys = {
            { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
            { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
            { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
            { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
        },
    },
}, {
    checker = {
        enabled = true, -- automatically check for plugin updates
        notify = false, -- don't pop up when opening that there are updates
    },
})
