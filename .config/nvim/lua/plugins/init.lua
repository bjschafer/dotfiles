-- ensure installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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
    -- undo improvements
    "mbbill/undotree",

    "joshdick/onedark.vim", -- optimal colorscheme

    "vim-scripts/ReplaceWithRegister",
    "justinmk/vim-sneak",
    "tpope/vim-fugitive",
    "tpope/vim-repeat",
    "tpope/vim-surround",

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
    },

    "ray-x/guihua.lua", -- floating windows

    "dhruvasagar/vim-table-mode", -- align markdown tables

    -- lsp
    {
        "VonHeikemen/lsp-zero.nvim",
        dependencies = {
            { "neovim/nvim-lspconfig" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },

            -- Autocompletion
            { "hrsh7th/nvim-cmp" }, -- Required
            { "hrsh7th/cmp-nvim-lsp" }, -- Required
            { "L3MON4D3/LuaSnip" }, -- Required
        },
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
    },

    {
        "iamcco/markdown-preview.nvim",
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
    },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons", opt = true },
    },
    { "akinsho/bufferline.nvim", version = "v4.*", dependencies = "nvim-tree/nvim-web-devicons" },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.3",
        dependencies = { { "nvim-lua/plenary.nvim" } },
    },
    {
        "ThePrimeagen/harpoon",
        dependencies = { { "nvim-lua/plenary.nvim" } },
    },

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
    },
}, {
    checker = {
        enabled = true, -- automatically check for plugin updates
        notify = false, -- don't pop up when opening tha there's updates
    },
})
