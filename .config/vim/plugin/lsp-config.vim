vim9script
# Language servers, ported from lua/configs/lsp in ~/.config/nvim.

var git_root = ['.git/', '.git']

var servers = [
    {
        name: 'lua_ls', filetype: ['lua'], path: 'lua-language-server', args: [],
        rootSearch: ['.luarc.json', '.luarc.jsonc', '.stylua.toml', 'stylua.toml', 'init.lua'] + git_root,
        workspaceConfig: {Lua: {runtime: {version: 'LuaJIT'}, telemetry: {enable: false}}},
    },
    {
        name: 'ty', filetype: ['python'], path: 'uvx', args: ['ty', 'server'],
        rootSearch: ['pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile'] + git_root,
    },
    {
        name: 'gopls', filetype: ['go', 'gomod', 'gowork', 'gotmpl'], path: 'gopls', args: [],
        rootSearch: ['go.work', 'go.mod'] + git_root, syncInit: true,
        # gopls only sends semantic tokens when asked; they stand in for tree-sitter.
        workspaceConfig: {gopls: {semanticTokens: true}},
    },
    {
        name: 'vtsls', filetype: ['javascript', 'javascriptreact', 'typescript', 'typescriptreact'],
        path: 'vtsls', args: ['--stdio'],
        rootSearch: ['package.json', 'tsconfig.json', 'jsconfig.json'] + git_root,
    },
    {
        name: 'rust_analyzer', filetype: ['rust'], path: 'rust-analyzer', args: [],
        rootSearch: ['Cargo.toml', 'rust-project.json'] + git_root, syncInit: true,
    },
    {
        name: 'bashls', filetype: ['sh', 'bash'], path: 'bash-language-server', args: ['start'],
        rootSearch: git_root,
    },
    {
        name: 'terraformls', filetype: ['terraform', 'tf', 'hcl'], path: 'terraform-ls', args: ['serve'],
        rootSearch: ['.terraform/'] + git_root,
    },
    {
        name: 'rumdl', filetype: ['markdown'], path: 'rumdl', args: ['server'],
        rootSearch: git_root,
    },
    {
        name: 'yamlls', filetype: ['yaml'], path: 'yaml-language-server', args: ['--stdio'],
        rootSearch: git_root,
        workspaceConfig: {yaml: {
            schemaStore: {enable: true, url: 'https://www.schemastore.org/api/json/catalog.json'},
            schemas: {
                kubernetes: '/tmp/kubectl-edit-*.yaml',
                'http://json.schemastore.org/github-workflow': '.github/workflows/*',
                'http://json.schemastore.org/github-action': '.github/action.{yml,yaml}',
                'http://json.schemastore.org/ansible-stable-2.9': 'roles/tasks/*.{yml,yaml}',
                'http://json.schemastore.org/prettierrc': '.prettierrc.{yml,yaml}',
                'http://json.schemastore.org/kustomization': 'kustomization.{yml,yaml}',
                'http://json.schemastore.org/ansible-playbook': '*play*.{yml,yaml}',
                'http://json.schemastore.org/chart': 'Chart.{yml,yaml}',
                'https://json.schemastore.org/dependabot-v2': '.github/dependabot.{yml,yaml}',
                'https://json.schemastore.org/gitlab-ci': '*gitlab-ci*.{yml,yaml}',
                'https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json': '*api*.{yml,yaml}',
            },
        }},
    },
    {
        name: 'zls', filetype: ['zig'], path: 'zls', args: [],
        rootSearch: git_root,
    },
]

def Setup()
    g:LspOptionsSet({
        autoComplete: true,
        useBufferCompletion: true,
        completionMatcher: 'fuzzy',
        showDiagWithVirtualText: true,
        diagVirtualTextAlign: 'after',
        showDiagInPopup: true,
        showInlayHints: true,
        semanticHighlight: true,
        ignoreMissingServer: true,
    })
    g:LspAddServer(servers)
enddef

# Point yamlls at the Kubernetes schema for manifests with apiVersion and
# kind in the first 10 lines.
def KubernetesSchema()
    if &filetype != 'yaml'
        return
    endif
    var head = getline(1, 10)
    if head->indexof((_, l) => l =~ '^apiVersion:') < 0 || head->indexof((_, l) => l =~ '^kind:') < 0
        return
    endif
    var server = lsp#buffer#CurbufGetServerByName('yamlls')
    if server->empty()
        return
    endif
    var schemas = server.workspaceConfig.yaml.schemas
    var k8s = schemas.kubernetes
    schemas.kubernetes = (type(k8s) == v:t_list ? k8s : [k8s]) + [lsp#util#LspFileToUri(expand('%:p'))]
    server.sendNotification('workspace/didChangeConfiguration', {settings: server.workspaceConfig})
enddef

def OnAttach()
    b:lsp_attached = true
    &autocomplete = false

    nnoremap <buffer> gd <Cmd>LspGotoDefinition<CR>
    nnoremap <buffer> gD <Cmd>LspGotoDeclaration<CR>
    nnoremap <buffer> gi <Cmd>LspGotoImpl<CR>
    nnoremap <buffer> gr <Cmd>LspShowReferences<CR>
    nnoremap <buffer> K <Cmd>LspHover<CR>
    nnoremap <buffer> <C-k> <Cmd>LspShowSignature<CR>
    nnoremap <buffer> <Leader>rn <Cmd>LspRename<CR>
    nnoremap <buffer> <Leader>ca <Cmd>LspCodeAction<CR>
    nnoremap <buffer> <Leader>D <Cmd>LspGotoTypeDef<CR>
    nnoremap <buffer> <Leader>wa :LspWorkspaceAddFolder <C-R>=expand('%:p:h')<CR>
    nnoremap <buffer> <Leader>wr :LspWorkspaceRemoveFolder <C-R>=expand('%:p:h')<CR>
    nnoremap <buffer> <Leader>wl <Cmd>LspWorkspaceListFolders<CR>

    nnoremap <buffer> [d <Cmd>LspDiag prev<CR><Cmd>LspDiag current<CR>
    nnoremap <buffer> ]d <Cmd>LspDiag next<CR><Cmd>LspDiag current<CR>
    nnoremap <buffer> <Leader>dd <Cmd>LspDiag current<CR>
    nnoremap <buffer> <Leader>dq <Cmd>LspDiag show<CR>

    KubernetesSchema()
enddef

augroup lsp_config
    autocmd!
    autocmd User LspSetup Setup()
    autocmd User LspAttached OnAttach()
    # yegappan/lsp completes in buffers with a server; Vim's own
    # 'autocomplete' (buffer words) covers the rest, like blink's buffer source.
    autocmd BufEnter * &autocomplete = !get(b:, 'lsp_attached', false)
augroup END

set complete=.^5,w^5,b^5,u^5
set completeopt=menuone,popup,noselect,fuzzy

# Tab accepts the selected item, or the first one if none is selected
# (blink's super-tab preset).
inoremap <expr> <Tab> pumvisible() ? (complete_info(['selected']).selected == -1 ? "\<C-n>\<C-y>" : "\<C-y>") : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
