vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.api.nvim_set_option("clipboard", "unnamedplus")
vim.api.nvim_set_option("mouse", "")
vim.opt.relativenumber = true;
vim.opt.wrap = false
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.nu = true
vim.keymap.set("n", "<C-s>", vim.diagnostic.setqflist)
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.lua", "*.dart", "*.rs", "*.js", "*.ts", "*.sh", "*.zig", "*.odin", "*.go" },
	callback = function() vim.lsp.buf.format { async = false } end
})
for _, r in ipairs({
	{ pattern = "zig",  cmd = "zig build run" },
	{ pattern = "odin", cmd = "odin run ." },
	{ pattern = "rust", cmd = "cargo run" }
}) do
	vim.api.nvim_create_autocmd("FileType", {
		pattern = r.pattern,
		callback = function()
			vim.keymap.set("n", "<F5>", function()
				vim.cmd.vsplit()
				vim.cmd.wincmd("l")
				vim.cmd.terminal(r.cmd)
			end)
		end,
	})
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo(
			{ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" }, { "\nPress any key to exit..." } }, true,
			{}
		)
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	spec = {
		{
			"rose-pine/neovim",
			name = "rose-pine",
			config = function()
				vim.cmd("colorscheme rose-pine")
				vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
				vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
				vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
			end
		},
		"tpope/vim-fugitive",
		{ "windwp/nvim-autopairs", config = function() require("nvim-autopairs").setup {} end },
		{
			"nvim-telescope/telescope.nvim",
			config = function()
				local builtin = require("telescope.builtin")
				vim.keymap.set("n", "<C-p>", builtin.git_files, {})
				vim.keymap.set("n", "<C-f>", function() builtin.grep_string({ search = vim.fn.input("Grep > ") }) end)
			end
		},
		{
			"VonHeikemen/lsp-zero.nvim",
			dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim", "neovim/nvim-lspconfig", "hrsh7th/nvim-cmp", "L3MON4D3/LuaSnip", "hrsh7th/cmp-nvim-lsp" },
			config = function()
				local lsps = { "zls", "ols", "rust_analyzer", "gopls", "lua_ls", "tsserver", "eslint" }
				local lsp = require('lsp-zero').preset({})
				lsp.on_attach(function(_, bufnr) lsp.default_keymaps({ buffer = bufnr }) end)
				lsp.setup()
				for _, runner in ipairs(lsps) do require("lspconfig")[runner].setup {} end
				require("mason").setup()
				require("mason-lspconfig").setup({
					ensure_installed = lsps,
					handlers = { lsp.default_setup }
				})
				require('cmp').setup({
					sources = { { name = 'nvim_lsp' } },
					snippet = { expand = function(args) vim.snippet.expand(args.body) end },
					mapping = require('cmp').mapping.preset.insert({}),
				})
			end
		},
		{
			"akinsho/flutter-tools.nvim",
			dependencies = { 'nvim-lua/plenary.nvim', 'stevearc/dressing.nvim' },
			config = function()
				require("telescope").load_extension("flutter")
				require("flutter-tools").setup { flutter_path = os.getenv("HOME") .. "/flutter/bin/flutter", widget_guides = { enabled = true } }
				vim.api.nvim_create_autocmd("FileType", {
					pattern = "dart",
					callback = function() vim.keymap.set("n", "<F5>", require("telescope").extensions.flutter.commands) end,
				})
			end
		},
	},
})
