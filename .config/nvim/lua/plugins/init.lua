-- autoupdate when this file is changed
vim.cmd([[
augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins/init.lua source <afile> | PackerCompile
augroup end
]])

return require("packer").startup(function(use)
  -- Packer can manage itself
  use "wbthomason/packer.nvim"

  -- undo improvements
  use "mbbill/undotree"

  use "joshdick/onedark.vim" -- optimal colorscheme

  use "easymotion/vim-easymotion"
  use "justinmk/vim-sneak"
  use "tpope/vim-fugitive"
  use "tpope/vim-repeat"
  use "tpope/vim-surround"

  use {
	  "ray-x/go.nvim",
	  dependencies = {
		  "ray-x/guihua.lua",
		  "neovim/nvim-lspconfig",
		  "nvim-treesitter/nvim-treesitter",
	  },
	  config = function()
		  require("go").setup()
	  end,
	  event = {"CmdlineEnter"},
	  ft = {"go", "gomod"},
	  build = ":lua require('go.install').update_all_sync()"
  }

  use "neovim/nvim-lspconfig"
  use {
      "nvim-treesitter/nvim-treesitter",
      run = ":TSUpdate"
  }

  use "ray-x/guihua.lua" -- floating windows

  use "dhruvasagar/vim-table-mode" -- align markdown tables

  -- lsp
  use {
      "VonHeikemen/lsp-zero.nvim",
      requires = {
        { "neovim/nvim-lspconfig" },
        {
            "williamboman/mason.nvim",
            run = function()
                pcall(vim.cmd, "MasonUpdate")
            end,
        },
        { "williamboman/mason-lspconfig.nvim" },

        -- Autocompletion
        {'hrsh7th/nvim-cmp'},     -- Required
        {'hrsh7th/cmp-nvim-lsp'}, -- Required
        {'L3MON4D3/LuaSnip'},     -- Required
        }
    }

  use "lukas-reineke/indent-blankline.nvim"

  use {
      'iamcco/markdown-preview.nvim',
      run = function() vim.fn["mkdp#util#install"]() end,
  }

  use {
		'nvim-lualine/lualine.nvim',
		requires = { 'kyazdani42/nvim-web-devicons', opt = true }
	}
  use {'akinsho/bufferline.nvim', tag = "v4.*", requires = 'kyazdani42/nvim-web-devicons'}
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.1',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {
    'ThePrimeagen/harpoon',
     requires = { {'nvim-lua/plenary.nvim'} }
   }

   use {
    'folke/which-key.nvim',
	config = function()
	  require("which-key").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
	  }
	end
	}


  end)
