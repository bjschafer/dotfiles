local wk = require("which-key")
local mappings = {
    f = {
        name = "Telescope [F]ind",
        b = { "Buffers" },
        f = { "Files" },
        g = { "Grep (rg)" },
        h = { "Help" },
        k = { "Keymaps" },
        o = { "Old files" },
    },
    s = { ":set paste<CR>", "Set Paste" },
    n = { ":bn<CR>", "Next Buffer" },
    p = { ":bp<CR>", "Previous Buffer" },
    oy = { ":set ft=yaml.ansible<CR>", "Set file type = ansible" },
    ["="] = { "Equalize viewports" },
}

local opts = { prefix = "<leader>" }
wk.register(mappings, opts)
