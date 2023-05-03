return {
	"nvim-lua/plenary.nvim",
	"MunifTanjim/nui.nvim",

	-- LSP
	"AndrewRadev/tagalong.vim",
	"b0o/schemastore.nvim",
	"davidosomething/format-ts-errors.nvim",
	"jose-elias-alvarez/typescript.nvim",
	"jxnblk/vim-mdx-js",
	"neovim/nvim-lspconfig",
	"onsails/lspkind-nvim",
	"williamboman/mason-lspconfig.nvim",
	"williamboman/mason.nvim",

	-- General
	"github/copilot.vim",
	"junegunn/gv.vim",
	"nvim-lua/popup.nvim",
	"princejoogie/tailwind-highlight.nvim",
	"tpope/vim-fugitive",
	"tpope/vim-repeat",
	"tpope/vim-rhubarb",
	"tpope/vim-surround",

	{ "kevinhwang91/nvim-bqf", ft = { "qf" } },
	{
		"Wansmer/treesj",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		keys = {
			{ "<leader>s", "<cmd>TSJSplit", desc = "Treesj split" },
			{ "<leader>j", "<cmd>TSJJoin", desc = "Treesj join" },
		},
		config = function()
			require("treesj").setup()
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		build = "make install_jsregexp",
		dependencies = {
			"rafamadriz/friendly-snippets",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
	{
		"j-hui/fidget.nvim",
		config = function()
			require("fidget").setup()
		end,
	},
	{
		"dmmulroy/tsc.nvim",
		config = function()
			require("tsc").setup()
		end,
	},
	{
		"princejoogie/dir-telescope.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		config = function()
			require("dir-telescope").setup()
		end,
	},
	{
		"princejoogie/chafa.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "m00qek/baleia.nvim" },
		config = function()
			require("chafa").setup({
				render = { min_padding = 5, show_label = true },
				events = { update_on_nvim_resize = true },
			})
		end,
	},
	{
		"folke/zen-mode.nvim",
		dependencies = {
			{
				"folke/twilight.nvim",
				config = function()
					require("twilight").setup()
				end,
			},
		},
		config = function()
			require("zen-mode").setup()
		end,
	},
	{
		"folke/neodev.nvim",
		config = function()
			require("neodev").setup()
		end,
	},
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
	{ "ThePrimeagen/harpoon", dependencies = { "nvim-lua/plenary.nvim" } },
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
	{
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup()
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("treesitter-context").setup({ enable = true })
		end,
	},
	{
		"ggandor/leap.nvim",
		config = function()
			require("leap").add_default_mappings()
			vim.keymap.del({ "x", "o" }, "x")
			vim.keymap.del({ "x", "o" }, "X")
		end,
	},
	-- with others
	{
		"windwp/nvim-autopairs",
		config = function()
			require("others").nvim_autopairs()
		end,
	},
	{
		"akinsho/toggleterm.nvim",
		config = function()
			require("others").toggleterm()
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("others").indent_blankline()
		end,
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("others").nvim_colorizer()
		end,
	},
	{
		"numToStr/Comment.nvim",
		config = function()
			require("others").comment()
		end,
	},
	{
		"vuki656/package-info.nvim",
		config = function()
			require("others").package_info()
		end,
	},
	{
		"rcarriga/nvim-notify",
		config = function()
			local notify = require("notify")
			notify.setup({
				background_colour = "#000000",
				fps = 60,
				max_width = 120,
				max_height = 10,
				stages = "fade_in_slide_out",
			})

			local banned_messages = {
				"No information available",
				"Toggling hidden files",
			}

			vim.notify = function(msg, ...)
				for _, banned in ipairs(banned_messages) do
					if string.find(msg, banned) then
						return
					end
				end
				return notify(msg, ...)
			end
		end,
	},
}
