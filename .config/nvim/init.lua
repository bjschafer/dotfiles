require('options')
require('plugins')
require('keybindings')

require('configs/indent-blankline-config')
require('configs/lsp_config')
require('configs/treesitter-config')
require('configs/whichkey-config')

vim.cmd([[colorscheme onedark]])
