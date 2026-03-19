require("hodgeswt.set")
require("hodgeswt.remap")
require("hodgeswt.lazy_init")

local augroup = vim.api.nvim_create_augroup
local ThePrimeagenGroup = augroup('ThePrimeagen', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({"BufWritePre"}, {
    group = ThePrimeagenGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd('LspAttach', {
    group = ThePrimeagenGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)

        local client = vim.lsp.get_client_by_id(e.data.client_id)
        if client and client.name == 'pyright' then
            local function find_python_path()
                local bufpath = vim.api.nvim_buf_get_name(e.buf)
                local dir = vim.fn.fnamemodify(bufpath, ':h')

                -- Walk up to find project root
                local root = dir
                local markers = { 'uv.lock', 'pyproject.toml', 'setup.py', 'setup.cfg', '.git' }
                local current = dir
                while current ~= '/' do
                    for _, marker in ipairs(markers) do
                        if vim.fn.filereadable(current .. '/' .. marker) == 1
                            or vim.fn.isdirectory(current .. '/' .. marker) == 1 then
                            root = current
                            goto found_root
                        end
                    end
                    current = vim.fn.fnamemodify(current, ':h')
                end
                ::found_root::

                -- uv
                local uv = vim.fn.exepath('uv')
                if uv ~= '' then
                    local result = vim.fn.system('cd ' .. vim.fn.shellescape(root) .. ' && uv python find 2>/dev/null')
                    if vim.v.shell_error == 0 then
                        local path = vim.trim(result)
                        if path ~= '' and vim.fn.filereadable(path) == 1 then
                            return path
                        end
                    end
                end

                -- .venv or venv
                for _, venv in ipairs({ '/.venv/bin/python', '/venv/bin/python' }) do
                    local path = root .. venv
                    if vim.fn.filereadable(path) == 1 then return path end
                end

                -- pyenv via .python-version
                local version_file = root .. '/.python-version'
                if vim.fn.filereadable(version_file) == 1 then
                    local version = vim.trim(vim.fn.readfile(version_file)[1])
                    local path = vim.fn.expand('~/.pyenv/versions/' .. version .. '/bin/python')
                    if vim.fn.filereadable(path) == 1 then return path end
                end

                -- system fallback
                return vim.fn.exepath('python3')
            end

            local function set_python_path(path)
                if client.settings then
                    client.settings.python = vim.tbl_deep_extend('force', client.settings.python or {}, { pythonPath = path })
                else
                    client.config.settings = vim.tbl_deep_extend('force', client.config.settings or {}, { python = { pythonPath = path } })
                end
                client.notify('workspace/didChangeConfiguration', { settings = nil })
            end

            -- Auto-discover on attach
            set_python_path(find_python_path())

            vim.api.nvim_buf_create_user_command(e.buf, 'PyrightOrganizeImports', function()
                local params = {
                    command = 'pyright.organizeimports',
                    arguments = { vim.uri_from_bufnr(0) },
                }
                client.request('workspace/executeCommand', params, nil, 0)
            end, { desc = 'Organize Imports' })

            vim.api.nvim_buf_create_user_command(e.buf, 'PyrightSetPythonPath', function(args)
                local path = (args.args ~= '') and args.args or find_python_path()
                set_python_path(path)
            end, { desc = 'Set python path (auto-discovers if no arg given)', nargs = '?', complete = 'file' })
        end
    end
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
