return {
	"stevearc/conform.nvim",
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				cpp = { "clang-format" },
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
				lua = { "stylua" },
				python = { "isort", "black" },
			},
		})

		local format = function()
			local ft = vim.bo.ft
			local js_fts = {
				"javascript",
				"typescript",
				"javascriptreact",
				"typescriptreact",
			}

			for _, v in ipairs(js_fts) do
				if ft == v then
					vim.cmd("EslintFixAll")
					break
				end
			end

			conform.format({
				lsp_fallback = true,
				async = true,
			})
		end

		vim.keymap.set({ "n", "v" }, "<leader>p", format, { desc = "Format file or range" })

		vim.api.nvim_create_autocmd("BufWritePost", {
			group = vim.api.nvim_create_augroup("joogie_format_on_save", { clear = true }),
			callback = format,
		})
	end,
}
