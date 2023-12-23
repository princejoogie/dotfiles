return {
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
					-- Background styles. Can be "dark", "transparent" or "normal"
					sidebars = "transparent", -- style for sidebars, see below
					floats = "transparent", -- style for floating windows
				},
			})
			vim.cmd([[colorscheme tokyonight-night]])
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-github.nvim",
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
			pcall(require("telescope").load_extension, "gh")

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
		},
		config = function()
			require("neo-tree").setup({
				sources = {
					"filesystem",
					"git_status",
				},
				source_selector = {
					winbar = true,
					statusline = false,
					sources = {
						{ source = "filesystem", display_name = "   Files " },
						{ source = "git_status", display_name = "   Git " },
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
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		opts = {
			ensure_installed = {
				"dockerfile",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"lua",
				"markdown",
				"python",
				"sql",
				"tsx",
				"typescript",
				"yaml",
			},
		},
		build = ":TSUpdate",
	},

	{ "nvim-tree/nvim-web-devicons", lazy = true },
	{ "stevearc/dressing.nvim", event = "VeryLazy" },

	{
		"nvim-lualine/lualine.nvim",
		opts = {
			theme = "tokyonight",
		},
	},

	{
		"folke/which-key.nvim",
		lazy = true,
	},

	{
		-- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			-- See `:help gitsigns.txt`
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
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
}
