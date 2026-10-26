-- Guard rails for chezmoi-managed dotfiles:
--   * opening a target generated from a template marks it readonly and points at the source
--   * opening a modify_ target (app-owned JSON with some managed keys) says which keys are managed
--   * saving a plain managed target nudges toward `chezmoi re-add`
--   * saving a file in the source dir applies it
-- :ChezmoiSource opens the source of the current target; :ChezmoiReAdd re-adds it.
if vim.fn.executable("chezmoi") == 0 then
    return
end

local home = vim.fs.normalize("~")
local source_dir, by_target, by_source

local function notify(msg, level)
    vim.notify("chezmoi: " .. msg, level or vim.log.levels.WARN)
end

-- Map targets <-> sources once per session (chezmoi managed takes ~10ms), and
-- again after saving in the source dir, since that may add files.
local function load()
    by_target, by_source = {}, {}
    source_dir = vim.trim(vim.fn.system({ "chezmoi", "source-path" }))
    local out = vim.fn.system({ "chezmoi", "managed", "--include=files", "--path-style=all", "--format=json" })
    if vim.v.shell_error ~= 0 then
        return
    end
    local ok, entries = pcall(vim.json.decode, out)
    if not ok then
        return
    end
    for _, e in pairs(entries) do
        by_target[e.absolute] = e.sourceAbsolute
        by_source[e.sourceAbsolute] = e.absolute
    end
end

local function kind(source)
    local name = vim.fs.basename(source)
    if name:match("^modify_") then
        return "modify"
    elseif name:match("%.tmpl$") then
        return "template"
    end
    return "plain"
end

local function buf_path(buf)
    return vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
end

local function in_source_dir(path)
    return source_dir ~= "" and vim.startswith(path, source_dir .. "/")
end

local group = vim.api.nvim_create_augroup("chezmoi_guard", { clear = true })

vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function(args)
        local path = buf_path(args.buf)
        if not vim.startswith(path, home .. "/") then
            return
        end
        if not by_target then
            load()
        end
        local source = by_target[path]
        if not source then
            return
        end
        vim.b[args.buf].chezmoi_source = source
        local k = kind(source)
        if k == "template" then
            vim.bo[args.buf].readonly = true
            notify("generated from a template; edits here get overwritten. :ChezmoiSource to edit the template")
        elseif k == "modify" then
            notify("partly managed: keys in the managed JSON under .chezmoitemplates/ are reset on apply")
        end
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function(args)
        local path = buf_path(args.buf)
        if not vim.startswith(path, home .. "/") then
            return
        end
        if not by_target then
            load()
        end

        local source = vim.b[args.buf].chezmoi_source
        if source then
            if kind(source) == "template" then
                notify("this file is generated; the next apply will overwrite your change", vim.log.levels.ERROR)
            elseif kind(source) == "plain" then
                notify(
                    "managed file changed in place; :ChezmoiReAdd (or `chezmoi re-add`) to keep it",
                    vim.log.levels.INFO
                )
            end
            return
        end

        if not in_source_dir(path) then
            return
        end
        if not by_source[path] then
            load()
        end
        local target = by_source[path]
        if not target then
            return -- not a target itself (script, .chezmoitemplates/, ignore file, ...)
        end
        -- --no-tty: if the target changed since chezmoi last wrote it, fail instead of prompting
        vim.system({ "chezmoi", "--no-tty", "apply", "--source-path", path }, { text = true }, function(res)
            vim.schedule(function()
                if res.code == 0 then
                    notify("applied " .. target:gsub("^" .. vim.pesc(home), "~"), vim.log.levels.INFO)
                else
                    notify("apply failed, run `chezmoi apply " .. target .. "`:\n" .. res.stderr, vim.log.levels.ERROR)
                end
            end)
        end)
    end,
})

vim.api.nvim_create_user_command("ChezmoiSource", function()
    local source = vim.b.chezmoi_source
    if not source then
        notify("current file isn't managed by chezmoi")
        return
    end
    vim.cmd.edit(vim.fn.fnameescape(source))
end, { desc = "Chezmoi: edit the source of this target" })

-- Runs in a terminal split: with git.autoCommit on, re-add prompts for a commit message.
vim.api.nvim_create_user_command("ChezmoiReAdd", function()
    if not vim.b.chezmoi_source then
        notify("current file isn't managed by chezmoi")
        return
    end
    vim.cmd("botright split | terminal chezmoi re-add " .. vim.fn.shellescape(buf_path(0)))
end, { desc = "Chezmoi: re-add this target to the source" })
