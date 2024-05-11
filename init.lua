-- Darren Fielding's Neovim Config
-- 
-- SETUP
-- 1. Put this file in: `~/.config/nvim/init.lua`
-- 2. Download Hack Nerd Font and extract in `~/.local/share/fonts/`
-- 3. Install fzf and add `eval "$(fzf --bash)"` to `~/.profile`
--

-- [[ Options ]]
local set = vim.opt
set.number = true
set.relativenumber = true
set.hlsearch = false
set.shiftwidth = 4
set.softtabstop = 4
set.tabstop = 4
set.splitright = true
set.splitbelow = true
set.laststatus = 3
set.termguicolors = true
set.background = "dark"
set.cursorline = true
set.cursorcolumn = true
set.hidden = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- [[ Plugins ]]
-- Get plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	-- [[ Editor plugins ]]
	{
		"windwp/nvim-autopairs", -- autopair parens, quotes, etc.
		event = "InsertEnter",
		opts = {}
	},
	{
		"nvim-treesitter/nvim-treesitter", -- syntax highlighting
		build = ":TSUpdate"
	},
	{
		"ibhagwan/fzf-lua", -- fuzzy finder
		dependencies = {"nvim-tree/nvim-web-devicons"},
		config = function()
			require("fzf-lua").setup({})
		end
	},
	{
		"nvim-tree/nvim-tree.lua", -- file tree explorer
		version = "*",
		lazy = false,
		dependencies = {"nvim-tree/nvim-web-devicons"},
		config = function()
			require("nvim-tree").setup {}
		end,
	},
	{
		'nvim-lualine/lualine.nvim', -- status line
		dependencies = { 'nvim-tree/nvim-web-devicons' }
	},
	{
		'crispgm/nvim-tabline',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = true,
	},
	{"HiPhish/rainbow-delimiters.nvim"}, -- colour-coded delimiters
	{
		"sontungexpt/witch", -- colour scheme with window dimming
		priority = 1000,
		lazy = false,
		config = function(_, opts)
			require("witch").setup(opts)
		end,
	},
	{'akinsho/toggleterm.nvim', version = "*", config = true}, -- terminal(s)

	-- [[ LSP plugins ]]
	{'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
	{'williamboman/mason.nvim'},
	{'williamboman/mason-lspconfig.nvim'},
	{'neovim/nvim-lspconfig'},
	{'L3MON4D3/LuaSnip'},
	{'hrsh7th/nvim-cmp'},
	{'hrsh7th/cmp-nvim-lsp'},
	{'hrsh7th/cmp-buffer'},
	{'hrsh7th/cmp-path'},
	{'saadparwaiz1/cmp_luasnip'},
	{'rafamadriz/friendly-snippets'},
	{'dgagn/diagflow.nvim', event = "LspAttach", opts = {}}
})

-- [[ Editor plugin setup ]]
require("nvim-tree").setup()
require("nvim-treesitter.configs").setup {
	ensure_installed = { "c", "lua", "zig" },
	auto_install = true,
}
require("lualine").setup()
require("tabline").setup({
	show_icon = true,
})
require("toggleterm").setup{
	size = 20,
	open_mapping = [[<leader>`]],
}
local map = vim.api.nvim_set_keymap
map("n", "<leader>t", ":NvimTreeToggle<CR>", {})
map("n", "<leader>ff", ":FzfLua files<CR>", {})
map("n", "<leader>fg", ":FzfLua grep<CR>", {})
map("t", "<Esc>", [[<C-\><C-n>]], {})

-- [[ LSP plugin setup ]]
local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(client, bufnr)
	lsp_zero.default_keymaps({buffer = bufnr})
end)
lsp_zero.set_sign_icons({
	error = '✘',
	warn = '▲',
	hint = '⚑',
	info = '»'
})

require("diagflow").setup()

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = { "clangd", "lua_ls", "zls"},
	automatic_installation = true,
	handlers = {
		lsp_zero.default_setup,
		lua_ls = function()
			local lua_opts = lsp_zero.nvim_lua_ls()
			require('lspconfig').lua_ls.setup(lua_opts)
		end,
	}
})

local cmp = require('cmp')
local cmp_action = lsp_zero.cmp_action()
require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
	sources = {
		{name = 'path'},
		{name = 'nvim_lsp'},
		{name = 'luasnip', keyword_length = 2},
		{name = 'buffer', keyword_length = 3},
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<Enter>'] = cmp.mapping.confirm({ select = true }),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-u>'] = cmp.mapping.scroll_docs(-4),
		['<C-d>'] = cmp.mapping.scroll_docs(4),   
		['<C-f>'] = cmp_action.luasnip_jump_forward(),
		['<C-b>'] = cmp_action.luasnip_jump_backward(),
	}),
	formatting = lsp_zero.cmp_format(),
})
