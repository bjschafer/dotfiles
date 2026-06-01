local status_ok, conform = pcall(require, "conform")
if not status_ok then
    return
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
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
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
