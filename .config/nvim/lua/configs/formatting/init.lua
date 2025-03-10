local conform = require("conform")

conform.setup({
    formatters_by_ft = {
        awk = { "awk" },
        fish = { "fish_indent" },
        go = { "goimports", "gofmt" },
        json = { "jq" },
        --        kdl = { "kdlfmt" }, -- this may not be an improvement
        lua = { "stylua" },
        markdown = { "cbfmt" },
        terraform = { "hcl", command = "terraform fmt" },
        yq = { "yq" },
        -- Conform will run multiple formatters sequentially
        python = { "isort", "black" },
        -- You can customize some of the format options for the filetype (:help conform.format)
        rust = { "rustfmt", lsp_format = "fallback" },
        sh = { "shfmt" },
        toml = { "taplo" },
        -- Conform will run the first available formatter
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
    },
    format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 500,
        lsp_format = "fallback",
    },
})

conform.formatters.shfmt = {
    prepend_args = { "-i", "4" },
}
