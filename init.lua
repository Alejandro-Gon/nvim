require("packer")

local treesitter = require("nvim-treesitter.configs");
local comments = require("Comment.api");
local lsp_zero = require("lsp-zero")
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local telescope = require("telescope")
local builtin = require("telescope.builtin")
local flutterTools = require("flutter-tools")
local lspconfig = require('lspconfig');
telescope.load_extension("flutter")
lsp_zero.preset("recommended")

local servers = {
	rust_analyzer = {
		["rust-analyzer"] = {
			checkOnSave = {
				command = "clippy",
			},
		},
	},
	lua_ls = {},
	taplo = {},
}

-- Settings
vim.opt.termguicolors = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.api.nvim_set_option("clipboard", "unnamedplus")
vim.api.nvim_set_option("mouse", "")
vim.opt.nu = true
vim.opt.relativenumber = true;
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.hlsearch = false

-- Keymaps
vim.keymap.set("x", "p", "P")
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>dl", vim.diagnostic.setqflist)
vim.keymap.set("n", "<leader>/", ":vsplit<cr><C-w>l")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-/>", comments.toggle.linewise.current)
vim.keymap.set("n", "<F5>", telescope.extensions.flutter.commands)
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<C-f>", function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)

-- Configs

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = {
		"*.lua",
		"*.dart",
		"*.rs",
		"*.js",
		"*.ts",
	},
	callback = function()
		vim.lsp.buf.format { async = false }
	end
})

lsp_zero.on_attach(function(_, bufnr)
	lsp_zero.default_keymaps({ buffer = bufnr })
end)

mason.setup({})
mason_lspconfig.setup({
	ensure_installed = vim.tbl_keys(servers),
	handlers = {
		lsp_zero.default_setup,
	},

})
mason_lspconfig.setup_handlers {
	function(server_name)
		lspconfig[server_name].setup {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers[server_name],
		}
	end
}

treesitter.setup {
	ensure_installed = { "javascript", "typescript", "dart", "cpp", "dockerfile", "cmake", "go", "kotlin", "java", "toml", "yaml", "c", "lua", "rust" },
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = true,
	},
}

flutterTools.setup {
	widget_guides = {
		enabled = true,
	},
}
