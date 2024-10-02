require("options")
require("plugins")
require("keybindings")

require("configs/bufferline")
require("configs/formatting")
require("configs/harpoon")
require("configs/indent-blankline")
require("configs/lsp")
require("configs/lualine")
require("configs/telescope")
require("configs/treesitter")
require("configs/whichkey")

require("neovide")

vim.cmd([[colorscheme catppuccin-frappe]])
