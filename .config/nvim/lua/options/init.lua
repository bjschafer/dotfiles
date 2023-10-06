vim.opt.background = "dark"
vim.opt.mouse = "a"
vim.opt.mousehide = true

if vim.fn.has("clipboard") == 1 then
    vim.opt.clipboard = { "unnamed" }
    if vim.fn.has("unnamedplus") then
        vim.opt.clipboard:append({ "unnamedplus" })
    end
end

vim.opt.shortmess = "filmnrxoOtT" -- Abbrev. of messages (avoids 'hit enter')
vim.opt.viewoptions = { "options", "cursor", "unix", "slash" } -- Better Unix / Windows compatibility
vim.opt.virtualedit = "onemore" -- Allow for cursor beyond last character
vim.opt.history = 1000 -- Store a ton of history (default is 20)
vim.opt.hidden = true -- Allow buffer switching without saving

vim.opt.iskeyword:remove({ ".", "#", "-" }) -- these are end of word designators

-- tabs settings
vim.opt.wrap = false -- do not wrap long lines
vim.opt.autoindent = true -- indent at the same level as the previous line
vim.opt.shiftwidth = 4 -- use indents of 4 spaces
vim.opt.tabstop = 4 -- an indentation every four columns
vim.opt.expandtab = true -- tabs are spaces, not tabs
vim.opt.smartindent = true -- smart autoindent when starting a new line
vim.opt.joinspaces = false -- prevent inserting two spaces after punctuation on a join (J)

-- set pastetoggle=<f5>

vim.opt.undofile = true
vim.opt.undolevels = 10000 -- max number of changes that can be undone
vim.opt.undoreload = 10000 -- max number of lines to save for undo on a buffer reload
vim.opt.undodir = vim.fs.normalize("~/.config/nvim/undo")

vim.opt.number = true
vim.opt.relativenumber = true
