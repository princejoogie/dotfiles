return {
	"AndrewRadev/tagalong.vim",
	"sindrets/diffview.nvim",
	{
		"ThePrimeagen/git-worktree.nvim",
		config = function()
			local link_env = require("joogie.utils.link-env")
			local worktree = require("git-worktree")
			worktree.setup()

			worktree.on_tree_change(function(op, metadata)
				-- TODO: handle errors
				-- metadata.path can return just the branch name, so we need to expand it
				if op == worktree.Operations.Switch then
					link_env.link(metadata.path)
				end
			end
			)
		end,
	},
	{
		"folke/which-key.nvim",
		opts = { win = { border = "rounded" } }, },
	{ "nvim-tree/nvim-web-devicons", lazy = true },
	{ "stevearc/dressing.nvim", event = "VeryLazy" },

	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				transparent = true,
				styles = {
					comments = { italic = false },
					keywords = { italic = false },
					functions = {},
					variables = {},
					sidebars = "transparent",
					floats = "transparent",
				},
				on_highlights = function(hl)
					hl.WinSeparator = {
						fg = "#3b4261",
					}
				end,
			})
			vim.cmd([[colorscheme tokyonight-night]])
		end,
	},

	{ "ThePrimeagen/harpoon", dependencies = { "nvim-lua/plenary.nvim" } },

	{ "nvim-pack/nvim-spectre", opts = {} },

	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-github.nvim",
			{
				"princejoogie/dir-telescope.nvim",
				--[[ dir = "~/Documents/codes/lua/dir-telescope.nvim", ]]
				opts = { show_preview = false },
			},
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
		},
		config = function()
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "gh")
			pcall(require("telescope").load_extension, "git_worktree")

			local telescope = require("telescope")

			local ignored = {
				"node_modules",
				".git",
				".next",
				".turbo",
				".vercel",
				".expo",
				".open-next",
				".sst",
				".pio",
				"dist",
				"build",
				"out",
				"yarn.lock",
				"package-lock.json",
				"pnpm-lock.yaml",
				"npm-debug.log",
				"yarn-debug.log",
				"yarn-error.log",
				".pnpm-debug.log",
				".tsbuildinfo",
			}

			local rg_globs = {}

			for _, pattern in ipairs(ignored) do
				table.insert(rg_globs, "--glob")
				table.insert(rg_globs, "!" .. pattern)
			end

			telescope.setup({
				defaults = {
					preview = {
						treesitter = false,
					},
					prompt_prefix = "   ",
					sorting_stratey = "ascending",
					vimgrep_arguments = {
						"rg",
						"-L",
						"-uu",
						"--hidden",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						---@diagnostic disable-next-line: deprecated
						unpack(rg_globs),
					},
				},
				pickers = {
					find_files = {
						find_command = {
							"rg",
							"-uu",
							"--files",
							"--hidden",
							---@diagnostic disable-next-line: deprecated
							unpack(rg_globs),
						},
					},
				},
			})
		end,
	},

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			{ "s1n7ax/nvim-window-picker", opts = {} },
		},
		config = function()
			require("neo-tree").setup({
				window = {
					mappings = {
						["<C-b>"] = "noop",
						["/"] = "noop",
					},
				},
				filesystem = {
					follow_current_file = {
						enabled = true,
					},
					filtered_items = {
						hide_dotfiles = false,
					},
					hijack_netrw_behavior = "open_default",
				},
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				config = function()
					local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
					local configs = require("nvim-treesitter.configs")
					for name, fn in pairs(move) do
						if name:find("goto") == 1 then
							move[name] = function(q, ...)
								if vim.wo.diff then
									local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
									for key, query in pairs(config or {}) do
										if q == query and key:find("[%]%[][cC]") then
											vim.cmd("normal! " .. key)
											return
										end
									end
								end
								return fn(q, ...)
							end
						end
					end
				end,
			},
		},
		opts = {
			autotag = {
				enable = true,
				filetypes = {
					"html",
					"javascript",
					"javascriptreact",
					"jsx",
					"markdown",
					"tsx",
					"typescript",
					"typescriptreact",
					"prisma",
				},
			},
			ensure_installed = {
				"dockerfile",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"lua",
				"markdown",
				"prisma",
				"python",
				"sql",
				"tsx",
				"typescript",
				"yaml",
			},
			highlight = { enable = true, additional_vim_regex_highlighting = false },
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-Space>",
					node_incremental = "<C-Space>",
					scope_incremental = false,
					node_decremental = "<BS>",
				},
			},
			textobjects = {
				move = {
					enable = true,
					goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
					goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
					goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
					goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
				},
			},
		},
		config = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				---@type table<string, boolean>
				local added = {}
				opts.ensure_installed = vim.tbl_filter(function(lang)
					if added[lang] then
						return false
					end
					added[lang] = true
					return true
				end, opts.ensure_installed)
			end
			require("nvim-treesitter.configs").setup(opts)
		end,
		build = ":TSUpdate",
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
		keys = {
			{ "<c-space>", desc = "Increment selection" },
			{ "<bs>", desc = "Decrement selection", mode = "x" },
		},
	},

	{
		"vuki656/package-info.nvim",
		opts = {
			icons = {
				enable = true,
				style = {
					up_to_date = "|  ",
					outdated = "|  ",
				},
			},
			autostart = false,
			hide_up_to_date = true,
			hide_unstable_versions = false,
		},
	},

	{
		"folke/trouble.nvim",
		dependencies = {},
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
		},
		opts = {},
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	{
		"numToStr/Comment.nvim",
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
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
		"rcarriga/nvim-notify",
		config = function()
			local notify = require("notify")
			notify.setup({
				background_colour = "#000000",
				fps = 60,
				stages = "fade_in_slide_out",
				timeout = 3000,
				max_height = function()
					return math.floor(vim.o.lines * 0.75)
				end,
				max_width = function()
					return math.floor(vim.o.columns * 0.75)
				end,
				on_open = function(win)
					vim.api.nvim_win_set_config(win, { zindex = 100 })
				end,
			})

			local banned_messages = {
				"Neo-tree",
				"No information available",
				"Toggling hidden files",
				"Failed to attach to",
				"No items, skipping",
				"Config Change Detected",
				"Executing query",
				"Done after",
			}

			vim.notify = function(msg, ...)
				for _, banned in ipairs(banned_messages) do
					if string.find(msg, banned, 1, true) then
						return
					end
				end
				return notify(msg, ...)
			end
		end,
		keys = {
			{
				"<leader>un",
				function()
					require("notify").dismiss({ silent = true, pending = true })
				end,
				desc = "Dismiss all Notifications",
			},
		},
	},

	{
		"nvim-lualine/lualine.nvim",
		opts = {
			theme = "tokyonight",
		},
	},

	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "│" },
				change = {
					text = "│",
				},
				delete = { text = "_" },
				topdelete = {
					text = "‾",
				},
				changedelete = {
					text = "~",
				},
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map({ "n", "v" }, "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Jump to next hunk" })

				map({ "n", "v" }, "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Jump to previous hunk" })

				-- Actions
				-- visual mode
				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "stage git hunk" })
				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "reset git hunk" })
				-- normal mode
				map("n", "<leader>hs", gs.stage_hunk, { desc = "git stage hunk" })
				map("n", "<leader>hr", gs.reset_hunk, { desc = "git reset hunk" })
				map("n", "<leader>hS", gs.stage_buffer, { desc = "git Stage buffer" })
				map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
				map("n", "<leader>hR", gs.reset_buffer, { desc = "git Reset buffer" })
				map("n", "<leader>hp", gs.preview_hunk, { desc = "preview git hunk" })
				map("n", "<leader>hb", function()
					gs.blame_line({ full = false })
				end, { desc = "git blame line" })
				map("n", "<leader>hd", gs.diffthis, { desc = "git diff against index" })
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, { desc = "git diff against last commit" })

				-- Toggles
				map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "toggle git blame line" })
				map("n", "<leader>td", gs.toggle_deleted, { desc = "toggle git show deleted" })

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "select git hunk" })
			end,
		},
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
	},
}
