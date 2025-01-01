-- HARPOON

-- END HARPOON

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set('n', '<leader>sd', '<cmd>Telescope lsp_document_symbols<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>sr', '<cmd>Telescope lsp_references<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { noremap = true, silent = true})

vim.keymap.set('n', '<leader>b', '<C-o>', { noremap = true, silent= true})

