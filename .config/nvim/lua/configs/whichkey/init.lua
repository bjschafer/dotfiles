local status_ok, wk = pcall(require, "which-key")
if not status_ok then
    return
end

local mappings = {
    -- Misc
    { "?", desc = "Show all keymaps" },
    { "<F6>", desc = "Toggle line numbers" },

    { "<leader>=", desc = "Equalize viewports" },
    { "<leader>l", desc = "Toggle list chars" },

    -- Flash (motion)
    { "s", desc = "Flash jump", mode = { "n", "x", "o" } },
    { "S", desc = "Flash Treesitter", mode = { "n", "x", "o" } },
    { "r", desc = "Flash remote", mode = "o" },
    { "R", desc = "Flash Treesitter search", mode = { "o", "x" } },
    { "<C-s>", desc = "Toggle Flash search", mode = "c" },

    -- Git hunk navigation (buffer-local via gitsigns)
    { "]c", desc = "Next hunk" },
    { "[c", desc = "Prev hunk" },

    -- Diagnostic navigation (buffer-local via LSP)
    { "]d", desc = "Next diagnostic" },
    { "[d", desc = "Prev diagnostic" },

    -- Mini.surround
    { "sa", desc = "Add surrounding", mode = { "n", "v" } },
    { "sd", desc = "Delete surrounding" },
    { "sr", desc = "Replace surrounding" },
    { "sf", desc = "Find surrounding (right)" },
    { "sF", desc = "Find surrounding (left)" },
    { "sh", desc = "Highlight surrounding" },
    { "sn", desc = "Update n_lines" },

    -- Mini.operators
    { "g=", desc = "Evaluate (mini.operators)", mode = { "n", "v" } },
    { "gx", desc = "Exchange (mini.operators)", mode = { "n", "v" } },
    { "gm", desc = "Multiply/duplicate (mini.operators)", mode = { "n", "v" } },
    { "gs", desc = "Sort (mini.operators)", mode = { "n", "v" } },

    -- BufferLine
    { "<leader>b", group = "BufferLine" },
    { "<leader>bN", desc = "Move next" },
    { "<leader>bP", desc = "Move prev" },

    -- Explorer
    { "<leader>e", group = "Explorer" },
    { "<leader>eb", desc = "Explore Buffers" },
    { "<leader>ee", desc = "Explore CWD" },
    { "<leader>eg", desc = "Explore Git" },

    -- Diagnostics
    { "<leader>d", group = "Diagnostics" },
    { "<leader>dd", desc = "Open float" },
    { "<leader>dq", desc = "Set loclist" },

    -- Telescope
    { "<leader>f", group = "Find (Telescope)" },
    { "<leader>fb", desc = "Buffers" },
    { "<leader>ff", desc = "Files" },
    { "<leader>fg", desc = "Grep (rg)" },
    { "<leader>fh", desc = "Help tags" },
    { "<leader>fk", desc = "Keymaps" },
    { "<leader>fo", desc = "Old files" },
    { "<leader>fs", desc = "Git status" },

    -- Git
    { "<leader>g", group = "Git" },
    { "<leader>gb", desc = "Blame line" },
    { "<leader>gd", desc = "Diff this" },
    { "<leader>gp", desc = "Preview hunk" },
    { "<leader>gr", desc = "Reset hunk" },
    { "<leader>gs", desc = "Stage hunk" },

    -- Harpoon
    { "<leader>h", group = "Harpoon" },
    { "<leader>ha", desc = "Add file" },
    { "<leader>hh", desc = "Open menu" },
    { "<leader>h1", desc = "Select 1" },
    { "<leader>h2", desc = "Select 2" },
    { "<leader>h3", desc = "Select 3" },
    { "<leader>h4", desc = "Select 4" },
    { "<leader>hp", desc = "Previous" },
    { "<leader>hn", desc = "Next" },

    -- Buffers
    { "<leader>n", desc = "Next buffer" },
    { "<leader>p", desc = "Previous buffer" },

    -- Other
    { "<leader>o", group = "Options" },
    { "<leader>oy", desc = "Set filetype = ansible" },
}

wk.add(mappings)
