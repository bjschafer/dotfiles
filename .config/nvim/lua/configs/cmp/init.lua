local cmp_ok, cmp = pcall(require, "cmp")
if not cmp_ok then
    return
end

local luasnip_ok, luasnip = pcall(require, "luasnip")
if luasnip_ok then
    local vscode_loader_ok, vscode_loader = pcall(require, "luasnip.loaders.from_vscode")
    if vscode_loader_ok then
        vscode_loader.lazy_load()
    end
end

vim.opt.completeopt = { "menu", "menuone", "noselect" }

local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    if col == 0 then
        return false
    end
    local current_line = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
    return current_line:sub(col, col):match("%s") == nil
end

local primary_sources = {
    { name = "nvim_lsp" },
    { name = "path" },
}

if luasnip_ok then
    table.insert(primary_sources, { name = "luasnip" })
end

cmp.setup({
    snippet = {
        expand = function(args)
            if luasnip_ok then
                luasnip.lsp_expand(args.body)
            else
                vim.snippet.expand(args.body)
            end
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip_ok and luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip_ok and luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    sources = cmp.config.sources(primary_sources, {
        { name = "buffer" },
    }),
    formatting = {
        format = function(entry, vim_item)
            vim_item.menu = ({
                nvim_lsp = "[LSP]",
                buffer = "[Buf]",
                path = "[Path]",
                luasnip = "[Snip]",
            })[entry.source.name]
            return vim_item
        end,
    },
    experimental = {
        ghost_text = true,
    },
})
