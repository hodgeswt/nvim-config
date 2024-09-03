require'nvim-treesitter.configs'.setup {
	ensure_installed = { 'pkl', 'powershell', 'toml', 'json', 'bash', 'rust', 'javascript', 'typescript', 'c_sharp', 'c', 'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline' },
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
	},
}

vim.treesitter.language.register("bash", "sh")
