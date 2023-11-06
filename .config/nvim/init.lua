require("options")
require("plugins")
require("keybindings")

require("configs/bufferline-config")
require("configs/indent-blankline-config")
require("configs/lsp-config")
require("configs/lualine-config")
require("configs/telescope-config")
require("configs/treesitter-config")
require("configs/whichkey-config")

--vim.cmd([[colorscheme onedark]])
vim.cmd([[colorscheme catppuccin-frappe]])
