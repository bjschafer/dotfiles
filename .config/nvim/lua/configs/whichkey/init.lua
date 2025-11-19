local status_ok, wk = pcall(require, "which-key")
if not status_ok then
    return
end

local mappings = {
    { "<leader>=", desc = "Equalize viewports" },

    { "<leader>b", group = "BufferLine" },
    { "<leader>bN", desc = "Move next" },
    { "<leader>bP", desc = "Move prev" },

    { "<leader>e", group = "Explorer" },
    { "<leader>eb", desc = "Explore Buffers" },
    { "<leader>ee", desc = "Explore CWD" },
    { "<leader>eg", desc = "Explore Git" },

    { "<leader>f", group = "Telescope [F]ind" },
    { "<leader>fb", desc = "Buffers" },
    { "<leader>ff", desc = "Files" },
    { "<leader>fg", desc = "Grep (rg)" },
    { "<leader>fh", desc = "Help" },
    { "<leader>fk", desc = "Keymaps" },
    { "<leader>fo", desc = "Old files" },

    { "<leader>h", group = "Harpoon" },
    { "<leader>ha", desc = "Add file" },
    { "<leader>hh", desc = "Open menu" },
    { "<leader>h1", desc = "Select 1" },
    { "<leader>h2", desc = "Select 2" },
    { "<leader>h3", desc = "Select 3" },
    { "<leader>h4", desc = "Select 4" },
    { "<leader>hp", desc = "Previous" },
    { "<leader>hn", desc = "Next" },

    { "<leader>n", ":bn<CR>", desc = "Next Buffer" },
    { "<leader>oy", ":set ft=yaml.ansible<CR>", desc = "Set file type = ansible" },
    { "<leader>p", ":bp<CR>", desc = "Previous Buffer" },
    { "<leader>s", ":set paste<CR>", desc = "Set Paste" },
}

local opts = { prefix = "<leader>" }
wk.add(mappings, opts)
