vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.mouse = ""
vim.opt.clipboard = "unnamedplus"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" }, { "\nPress any key to exit..." } }, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	spec = {
		{
			"rose-pine/neovim", name = "rose-pine",
			config = function() vim.cmd("colorscheme rose-pine") end
		},
		{
			"nvim-telescope/telescope.nvim", dependencies = { 'nvim-lua/plenary.nvim' },
			config = function()
				vim.keymap.set("n", "<C-s>", function() vim.cmd(":Telescope diagnostics") end)
				vim.keymap.set("n", "<C-p>", function() vim.cmd(":Telescope find_files") end)
				vim.keymap.set("n", "<C-f>", function() require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") }) end)
			end
		},
		"tpope/vim-fugitive",
		"akinsho/flutter-tools.nvim",
		{
			"VonHeikemen/lsp-zero.nvim", dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim", "neovim/nvim-lspconfig", "hrsh7th/nvim-cmp", "L3MON4D3/LuaSnip", "hrsh7th/cmp-nvim-lsp" },
			config = function()
				local lsps = { "ts_ls", "eslint", "ols", }
				require('lsp-zero').on_attach(function(_, bufnr) require('lsp-zero').default_keymaps({ buffer = bufnr }) end)
				for _, runner in ipairs(lsps) do require("lspconfig")[runner].setup {} end
				require("mason").setup()
				require("mason-lspconfig").setup({ ensure_installed = lsps, handlers = { require('lsp-zero').default_setup } })
				require('cmp').setup({sources = {{name = 'nvim_lsp'}}, snippet = {expand = function(args) vim.snippet.expand(args.body) end}, mapping = require('cmp').mapping.preset.insert({})})
				vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.dart", "*.ts", "*.odin", }, callback = function() vim.lsp.buf.format { async = false } end })
			end
		},
	},
})
