return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				cpp = { "clang-format" },
				lua = { "stylua" },
				python = { "isort", "black" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				sql = { "sqlfmt" },
				nix = { "nixpkgs-fmt" },
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>p", function()
			local opts = {
				bufnr = 0,
				lsp_format = "fallback",
				async = true,
			}

			if vim.fn.mode() == "v" then
				local start_pos = vim.fn.getpos("'<")
				local end_pos = vim.fn.getpos("'>")
				opts.range = {
					start = { row = start_pos[2], col = start_pos[3] },
					end_pos = { row = end_pos[2], col = end_pos[3] },
				}
			end

			--[[ local is_js = false ]]
			--[[ for _, v in ipairs({ ]]
			--[[ 	"javascript", ]]
			--[[ 	"typescript", ]]
			--[[ 	"javascriptreact", ]]
			--[[ 	"typescriptreact", ]]
			--[[]]
			--[[ }) do ]]
			--[[ 	if vim.bo.ft == v then ]]
			--[[ 		is_js = true ]]
			--[[ 		break ]]
			--[[ 	end ]]
			--[[ end ]]
			--[[]]
			--[[ if is_js then ]]
			--[[ 	vim.cmd("EslintFixAll") ]]
			--[[ end ]]
			conform.format(opts)
		end, { desc = "Format file or range" })
	end,
}
