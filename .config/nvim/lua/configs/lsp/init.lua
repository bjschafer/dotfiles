-- LSP keybindings via LspAttach autocmd (vim.lsp.config does not support on_attach)
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf
        local opts = { buffer = bufnr, noremap = true, silent = true }

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)

        vim.keymap.set("n", "[d", function()
            vim.diagnostic.jump({ count = -1, float = true })
        end, opts)
        vim.keymap.set("n", "]d", function()
            vim.diagnostic.jump({ count = 1, float = true })
        end, opts)
        vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, opts)
    end,
})

-- Shared capabilities for all LSP servers
vim.lsp.config("*", {
    capabilities = vim.lsp.protocol.make_client_capabilities(),
})

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

-- Lua Language Server
vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = {
        ".luarc.json",
        ".luarc.jsonc",
        ".stylua.toml",
        "stylua.toml",
        ".git",
        "init.lua",
    },
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            telemetry = {
                enable = false,
            },
        },
    },
})

-- Python
vim.lsp.config("ty", {
    cmd = { "uvx", "ty", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
})

-- Go
vim.lsp.config("gopls", {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
})

-- JavaScript/TypeScript
vim.lsp.config("vtsls", {
    cmd = { "vtsls", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
})

-- Rust
vim.lsp.config("rust_analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
})

-- Shell
vim.lsp.config("bashls", {
    cmd = { "bash-language-server", "start" },
    filetypes = { "sh", "bash" },
    root_markers = { ".git" },
})

-- Terraform
vim.lsp.config("terraformls", {
    cmd = { "terraform-ls", "serve" },
    filetypes = { "terraform", "tf", "hcl" },
    root_markers = { ".terraform", ".git" },
})

-- Markdown
vim.lsp.config("rumdl", {
    cmd = { "rumdl", "server" },
    filetypes = { "markdown", "markdown.mdx" },
    root_markers = { ".git" },
})

-- YAML/Kubernetes
vim.lsp.config("yamlls", {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yml", "yaml", "yaml.docker-compose", "yaml.gitlab" },
    root_markers = { ".git" },
    settings = {
        yaml = {
            schemaStore = {
                enable = true,
                url = "https://www.schemastore.org/api/json/catalog.json",
            },
            schemas = {
                kubernetes = "/tmp/kubectl-edit-*.yaml",
                ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
                ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
                ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
                ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
                ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
                ["http://json.schemastore.org/ansible-playbook"] = "*play*.{yml,yaml}",
                ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
                ["https://json.schemastore.org/dependabot-v2"] = ".github/dependabot.{yml,yaml}",
                ["https://json.schemastore.org/gitlab-ci"] = "*gitlab-ci*.{yml,yaml}",
                ["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json"] = "*api*.{yml,yaml}",
            },
        },
    },
})

-- Zig
vim.lsp.config("zls", {
    cmd = { "zls" },
    filetypes = { "zig" },
    root_markers = { ".git" },
})

-- Enable configured language servers
vim.lsp.enable("lua_ls")
vim.lsp.enable("ty")
vim.lsp.enable("gopls")
vim.lsp.enable("vtsls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("bashls")
vim.lsp.enable("terraformls")
vim.lsp.enable("rumdl")
vim.lsp.enable("yamlls")
vim.lsp.enable("zls")

-- Enable inlay hints globally
vim.lsp.inlay_hint.enable()

-- Auto-detect Kubernetes YAML by checking for apiVersion/kind in the first 10 lines
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.yaml", "*.yml" },
    callback = function(args)
        local lines = vim.api.nvim_buf_get_lines(args.buf, 0, 10, false)
        local has_api_version = false
        local has_kind = false
        for _, line in ipairs(lines) do
            if line:match("^apiVersion:") then has_api_version = true end
            if line:match("^kind:") then has_kind = true end
        end
        if has_api_version and has_kind then
            local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "yamlls" })
            if #clients > 0 then
                local settings = clients[1].settings or {}
                settings.yaml = settings.yaml or {}
                settings.yaml.schemas = settings.yaml.schemas or {}
                settings.yaml.schemas["kubernetes"] = settings.yaml.schemas["kubernetes"] or {}
                local uri = vim.uri_from_bufnr(args.buf)
                if type(settings.yaml.schemas["kubernetes"]) == "string" then
                    settings.yaml.schemas["kubernetes"] = { settings.yaml.schemas["kubernetes"], uri }
                else
                    table.insert(settings.yaml.schemas["kubernetes"], uri)
                end
                clients[1]:notify("workspace/didChangeConfiguration", { settings = settings })
            end
        end
    end,
})

-- https://github.com/ThePrimeagen/init.lua/blob/249f3b14cc517202c80c6babd0f9ec548351ec71/after/plugin/lsp.lua#L31-L32
-- This is a really good dotfiles sample for configuring LSP in Neovim
-- Refer to this if you need it again in the future
