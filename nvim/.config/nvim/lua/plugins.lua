local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = vim.fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})

	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

local status_ok, packer = pcall(require, "packer")

if not status_ok then
	return
end

packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

return packer.startup(function(use)
	use("wbthomason/packer.nvim")
	use("nvim-lua/plenary.nvim")
	use({
		"lewis6991/impatient.nvim",
		config = function()
			require("impatient").enable_profile()
		end,
	})

	-- Custom
	--[[ use({ ]]
	--[[ 	"/home/joogie/Documents/codes/lua/plugins/mason-formatter.nvim", ]]
	--[[ 	config = function() ]]
	--[[ 		require("mason-formatter").setup({ ]]
	--[[        ensure_installed = {"autopep8"}, ]]
	--[[      }) ]]
	--[[ 	end, ]]
	--[[ }) ]]

	-- General
	use("AndrewRadev/tagalong.vim")
	use("MunifTanjim/nui.nvim")
	use("djoshea/vim-autoread")
	use("github/copilot.vim")
	use("junegunn/gv.vim")
	use("justinmk/vim-sneak")
	use("kyazdani42/nvim-web-devicons")
	use("nvim-lua/popup.nvim")
	use("princejoogie/tailwind-highlight.nvim")
	use("ryanoasis/vim-devicons")
	use("segeljakt/vim-silicon")
	use("tpope/vim-fugitive")
	use("tpope/vim-repeat")
	use("tpope/vim-rhubarb")
	use("tpope/vim-surround")
	use("tpope/vim-unimpaired")
	use("sudoerwx/vim-ray-so-beautiful")

	use({
		"romgrk/barbar.nvim",
		requires = { "kyazdani42/nvim-web-devicons" },
	})
	use({ "JoosepAlviste/nvim-ts-context-commentstring", requires = { "nvim-treesitter/nvim-treesitter" } })
	use({ "ThePrimeagen/harpoon", requires = { "nvim-lua/plenary.nvim" } })
	use({
		"iamcco/markdown-preview.nvim",
		run = "cd app && yarn install",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	})
	use({ "nvim-treesitter/playground", requires = { "nvim-treesitter/nvim-treesitter" } })
	use({ "tpope/vim-dispatch", opt = true, cmd = { "Dispatch", "Make", "Focus", "Start" } })

	use({
		"goolord/alpha-nvim",
		requires = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("configs.alpha").setup()
		end,
	})
	use({
		"windwp/nvim-autopairs",
		config = function()
			require("configs.others").nvim_autopairs()
		end,
	})
	use({
		"nvim-treesitter/nvim-treesitter-context",
		requires = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("configs.others").ts_context()
		end,
	})
	use({
		"akinsho/toggleterm.nvim",
		config = function()
			require("configs.others").toggleterm()
		end,
	})
	use({
		"nvim-tree/nvim-tree.lua",
		commit = "7282f7de8aedf861fe0162a559fc2b214383c51c",
		config = function()
			require("configs.others").nvim_tree()
		end,
	})
	use({
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("configs.others").indent_blankline()
		end,
	})
	use({
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("configs.others").nvim_colorizer()
		end,
	})
	use({
		"numToStr/Comment.nvim",
		config = function()
			require("configs.others").comment()
		end,
	})
	use({
		"vuki656/package-info.nvim",
		config = function()
			require("configs.others").package_info()
		end,
	})
	use({
		"windwp/nvim-ts-autotag",
		config = function()
			require("configs.others").nvim_ts_autotag()
		end,
	})

	-- Long Setups
	use({
		"mhartington/formatter.nvim",
		config = function()
			require("configs.formatter").setup()
		end,
	})
	use({
		"stevearc/dressing.nvim",
		config = function()
			require("configs.dressing").setup()
		end,
	})

	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("configs.gitsigns").setup()
		end,
		requires = { "nvim-lua/plenary.nvim" },
	})
	use({
		"nvim-lualine/lualine.nvim",
		config = function()
			require("configs.lualine").setup()
		end,
		requires = { "vuki656/package-info.nvim" },
	})
	use({
		"nvim-telescope/telescope.nvim",
		config = function()
			require("configs.telescope").setup()
		end,
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-dap.nvim",
			"nvim-telescope/telescope-github.nvim",
		},
	})
	use({
		"nvim-treesitter/nvim-treesitter",
		config = function()
			require("configs.treesitter").setup()
		end,
		run = ":TSUpdate",
	})

	use({
		"rcarriga/nvim-notify",
		config = function()
			local notify = require("notify")
			notify.setup({ background_colour = "#000000", fps = 60, level = 3, max_width = 120, max_height = 10 })
			vim.notify = notify
		end,
	})

	-- Debugging
	use("rcarriga/nvim-dap-ui")
	use("theHamsta/nvim-dap-virtual-text")
	use({
		"mfussenegger/nvim-dap",
		config = function()
			require("configs.nvim-dap").setup()
		end,
	})

	-- LSP
	use("arkav/lualine-lsp-progress")
	use("b0o/schemastore.nvim")
	use("hrsh7th/vim-vsnip")
	use("jose-elias-alvarez/null-ls.nvim")
	use("neovim/nvim-lspconfig")
	use("onsails/lspkind-nvim")
	use("jose-elias-alvarez/typescript.nvim")
	use("williamboman/mason.nvim")
	use("williamboman/mason-lspconfig.nvim")

	use({ "hrsh7th/cmp-vsnip", requires = { "onsails/lspkind-nvim" } })
	use({
		"hrsh7th/nvim-cmp",
		config = function()
			require("configs.nvim-cmp").setup()
		end,
		requires = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-emoji",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-vsnip",
		},
	})

	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
