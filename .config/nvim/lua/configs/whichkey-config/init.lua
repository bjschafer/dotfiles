local wk = require("which-key")
local mappings = {
  q = {":q<CR>", "Quit"},
  w = {":w<CR>", "Save"},
  z = {":wq<CR>", "Write and Quit"},
  x = {":bdelete<CR>", "Close the current buffer"},
  f = {":Telescope find_files<CR>", "Launch Telescope"},
  r = {":Telescope live_grep<CR>", "Telescope Live Grep"},
  s = {":set paste<CR>", "Set Paste"},
  n = {":bn<CR>", "Next Buffer"},
  oy = {":set ft=yaml.ansible<CR>", "Set file type = ansible"},
}

local opts = {prefix = '<leader>'}
wk.register(mappings, opts)
