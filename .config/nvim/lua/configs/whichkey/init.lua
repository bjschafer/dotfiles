local wk = require("which-key")

local mappings =  {
    { "<leader>=", desc = "Equalize viewports" },
    { "<leader>f", group = "Telescope [F]ind" },
    { "<leader>fb", desc = "Buffers" },
    { "<leader>ff", desc = "Files" },
    { "<leader>fg", desc = "Grep (rg)" },
    { "<leader>fh", desc = "Help" },
    { "<leader>fk", desc = "Keymaps" },
    { "<leader>fo", desc = "Old files" },
    { "<leader>n", ":bn<CR>", desc = "Next Buffer" },
    { "<leader>oy", ":set ft=yaml.ansible<CR>", desc = "Set file type = ansible" },
    { "<leader>p", ":bp<CR>", desc = "Previous Buffer" },
    { "<leader>s", ":set paste<CR>", desc = "Set Paste" },
  }

local opts = { prefix = "<leader>" }
wk.add(mappings, opts)
