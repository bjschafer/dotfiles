local status_ok, harpoon = pcall(require, "harpoon")
if not status_ok then
    return
end

---REQUIRED
harpoon:setup({})
---REQUIRED

vim.keymap.set("n", "<leader>ha", function()
    harpoon:list():add()
end, { desc = "Harpoon: Add file" })

vim.keymap.set("n", "<leader>h1", function()
    harpoon:list():select(1)
end, { desc = "Harpoon: Select 1" })

vim.keymap.set("n", "<leader>h2", function()
    harpoon:list():select(2)
end, { desc = "Harpoon: Select 2" })

vim.keymap.set("n", "<leader>h3", function()
    harpoon:list():select(3)
end, { desc = "Harpoon: Select 3" })

vim.keymap.set("n", "<leader>h4", function()
    harpoon:list():select(4)
end, { desc = "Harpoon: Select 4" })

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<leader>hp", function()
    harpoon:list():prev()
end, { desc = "Harpoon: Previous" })

vim.keymap.set("n", "<leader>hn", function()
    harpoon:list():next()
end, { desc = "Harpoon: Next" })

-- basic telescope configuration
local telescope_status, telescope_config = pcall(require, "telescope.config")
if not telescope_status then
    return
end
local conf = telescope_config.values
local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    require("telescope.pickers")
        .new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table({
                results = file_paths,
            }),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
        })
        :find()
end

vim.keymap.set("n", "<leader>hh", function()
    toggle_telescope(harpoon:list())
end, { desc = "Harpoon: Open menu" })
