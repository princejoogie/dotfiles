local formatter = safe_require("formatter")

if not formatter then
	return
end

local util = require("formatter.util")

local M = {}

local prettier = {
	function()
		return {
			exe = "node_modules/.bin/prettier",
			args = { "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) },
			stdin = true,
		}
	end,
}

local prismafmt = {
	function()
		return {
			exe = "prisma-fmt",
			args = { "format", "-i", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) },
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

M.setup = function()
	formatter.setup({
		filetype = {
			javascript = prettier,
			javascriptreact = prettier,
			typescript = prettier,
			typescriptreact = prettier,
			markdown = prettier,
			html = prettier,
			css = prettier,
			json = prettier,
			cpp = clang_format,
			lua = stylua,
			python = autopep8,
			prisma = prismafmt,
			rust = rustfmt,
			go = gofmt,
		},
	})
end

return M
