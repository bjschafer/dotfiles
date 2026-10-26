local status_ok, conform = pcall(require, "conform")
if not status_ok then
    return
end

-- oxfmt and prettier disagree about where to break call arguments, so whichever
-- one a project formats with, the other must never touch its files: with
-- format_on_save on, a single `:w` silently reflows the buffer into the losing
-- style and the project's CI format check fails on a file you only meant to
-- read. Pick per-buffer instead of globally -- oxfmt where the project actually
-- configures it, prettier everywhere else.
--
-- Deliberately keyed on oxfmt's own config files only. conform's built-in oxfmt
-- formatter also accepts vite.config.ts when resolving its cwd, but plenty of
-- Vite projects still format with Prettier, and matching that here would hijack
-- them.
local oxfmt_markers = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }

local function js_ts_formatters(bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= "" and vim.fs.root(name, oxfmt_markers) then
        return { "oxfmt" }
    end
    return { "prettierd", "prettier", stop_after_first = true }
end

conform.setup({
    formatters_by_ft = {
        awk = { "awk" },
        fish = { "fish_indent" },
        go = { "goimports", "gofmt" },
        json = { "jq" },
        --        kdl = { "kdlfmt" }, -- this may not be an improvement
        lua = { "stylua" },
        markdown = { "cbfmt" },
        terraform = { "tofu_fmt" },
        yaml = { "prettierd" },
        python = { "ruff_organize_imports", "ruff_format" },
        -- You can customize some of the format options for the filetype (:help conform.format)
        rust = { "rustfmt", lsp_format = "fallback" },
        sh = { "shfmt" },
        toml = { "taplo" },
        -- Conform will run the first available formatter
        javascript = js_ts_formatters,
        typescript = js_ts_formatters,
    },
    format_on_save = function(bufnr)
        local timeout_ms = vim.bo[bufnr].filetype == "terraform" and 3000 or 500
        return { timeout_ms = timeout_ms, lsp_format = "fallback" }
    end,
})

conform.formatters.shfmt = {
    prepend_args = { "-i", "4" },
}

conform.formatters.tofu_fmt = {
    command = "tofu",
    args = { "fmt", "-" },
    stdin = true,
}
