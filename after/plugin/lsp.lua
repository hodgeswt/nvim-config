local lsp = require('lsp-zero')

lsp.nvim_workspace()

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-space>'] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
    mapping = cmp_mappings
})

lsp.on_attach(function(_, bufnr)
    local opts = { buffer = bufnr, remap = False }
    attach(opts)
end)

lsp.preset('recommended')

lsp.ensure_installed({
    'csharp_ls',
    'elixirls',
    'gopls',
    'html',
    'tsserver',
    'jsonls',
    'lua_ls',
    'markdown_oxide',
    'powershell_es',
    'ruff_lsp',
    'sqlls',
    'harper_ls'
})

lsp.setup()
