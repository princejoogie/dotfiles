return {
	"nvim-lua/plenary.nvim",
	"AndrewRadev/tagalong.vim",
	"jxnblk/vim-mdx-js",
	"MunifTanjim/nui.nvim",
	--[[ "github/copilot.vim", ]]
	"junegunn/gv.vim",
	"nvim-lua/popup.nvim",
	"tpope/vim-fugitive",
	"tpope/vim-repeat",
	"tpope/vim-rhubarb",
	"tpope/vim-surround",
	"sindrets/diffview.nvim",
	"Eandrju/cellular-automaton.nvim",
	{ "kevinhwang91/nvim-bqf", ft = { "qf" } },
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {},
	},
	{
		"nvim-pack/nvim-spectre",
		config = function()
			require("spectre").setup()
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
		config = function()
			require("zen-mode").setup()
		end,
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
			require("which-key").setup({ window = { border = "single" } })
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
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true,
				ts_config = {
					lua = { "string" },
					javascript = { "template_string" },
					java = false,
				},
				disable_filetype = { "TelescopePrompt", "vim" },
			})
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			vim.opt.list = true
			require("indent_blankline").setup({
				space_char_blankline = " ",
				show_current_context = true,
				show_current_context_start = false,
			})
		end,
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({ "*" }, {
				RGB = true,
				RRGGBB = true,
				names = false,
				RRGGBBAA = true,
				rgb_fn = true,
				hsl_fn = true,
				css = true,
				css_fn = true,
				mode = "background",
			})
		end,
	},
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup({
				toggler = { line = "<leader>cl", block = "<leader>bl" },
				opleader = { line = "<leader>cc", block = "<leader>cb" },
				pre_hook = function(ctx)
					local U = require("Comment.utils")

					local location = nil
					if ctx.ctype == U.ctype.block then
						location = require("ts_context_commentstring.utils").get_cursor_location()
					elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
						location = require("ts_context_commentstring.utils").get_visual_start_location()
					end

					return require("ts_context_commentstring.internal").calculate_commentstring({
						key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
						location = location,
					})
				end,
			})
		end,
	},
	{
		"vuki656/package-info.nvim",
		config = function()
			require("package-info").setup({
				icons = {
					enable = true,
					style = {
						up_to_date = "|  ",
						outdated = "|  ",
					},
				},
				autostart = true,
				hide_up_to_date = true,
				hide_unstable_versions = false,
			})
		end,
	},
	{
		"stevearc/dressing.nvim",
		config = function()
			require("dressing").setup({ input = { default_prompt = "➤ " } })
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
				"Failed to attach to",
				"No items, skipping",
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
