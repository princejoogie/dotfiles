return {
	"mhartington/formatter.nvim",
	config = function()
		local formatter = require("formatter")
		local util = require("formatter.util")
		local keymap = vim.keymap.set

		local prettier = {
			function()
				return {
					exe = "prettier",
					args = { "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) },
					stdin = true,
				}
			end,
		}

		local rustfmt = {
			function()
				return {
					exe = "rustfmt",
					args = { "--emit=stdout", "--edition=2021" },
					stdin = true,
				}
			end,
		}

		local gofmt = {
			function()
				return {
					exe = "gofmt",
					args = {},
					stdin = true,
				}
			end,
		}

		local stylua = {
			function()
				return {
					exe = "stylua",
					args = {
						"--search-parent-directories",
						"--stdin-filepath",
						util.escape_path(util.get_current_buffer_file_path()),
						"--",
						"-",
					},
					stdin = true,
				}
			end,
		}

		local clang_format = {
			function()
				return {
					exe = "clang-format",
					args = { "--assume-filename", vim.api.nvim_buf_get_name(0) },
					stdin = true,
					cwd = vim.fn.expand("%:p:h"),
				}
			end,
		}

		local autopep8 = {
			function()
				return {
					exe = "python3 -m autopep8",
					args = {
						"--in-place --aggressive --aggressive",
						vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)),
					},
					stdin = false,
				}
			end,
		}

		local filetype_mapping = {
			javascript = prettier,
			javascriptreact = prettier,
			typescript = prettier,
			typescriptreact = prettier,
			markdown = prettier,
			html = prettier,
			css = prettier,
			json = prettier,
			yaml = prettier,
			cpp = clang_format,
			java = clang_format,
			lua = stylua,
			python = autopep8,
			rust = rustfmt,
			go = gofmt,
		}

		formatter.setup({
			filetype = filetype_mapping,
		})

		local FormatBuffer = function()
			if not filetype_mapping[vim.bo.filetype] then
				vim.lsp.buf.format()
			else
				vim.cmd("Format")
			end
		end

		keymap("n", "<leader>p", FormatBuffer)
	end,
}
