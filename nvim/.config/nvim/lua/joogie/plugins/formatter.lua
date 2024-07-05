return {
	"stevearc/conform.nvim",
	config = function()
		-- TEMPORARY: this config seems broken but eslint and prisma format still works
		--[[ require("conform").setup({ ]]
		--[[ 	formatters_by_ft = { ]]
		--[[ 		cpp = { "clang-format" }, ]]
		--[[ javascript = { "prettier" }, ]]
		--[[ typescript = { "prettier" }, ]]
		--[[ javascriptreact = { "prettier" }, ]]
		--[[ typescriptreact = { "prettier" }, ]]
		--[[ svelte = { "prettier" }, ]]
		--[[ css = { "prettier" }, ]]
		--[[ html = { "prettier" }, ]]
		--[[ json = { "prettier" }, ]]
		--[[ yaml = { "prettier" }, ]]
		--[[ markdown = { "prettier" }, ]]
		--[[ graphql = { "prettier" }, ]]
		--[[ 		lua = { "stylua" }, ]]
		--[[ 		python = { "isort", "black" }, ]]
		--[[ 	}, ]]
		--[[ }) ]]
		--[[ local format = function() ]]
		--[[ 	local ft = vim.bo.ft ]]
		--[[ 	local js_fts = { ]]
		--[[ 		"javascript", ]]
		--[[ 		"typescript", ]]
		--[[ 		"javascriptreact", ]]
		--[[ 		"typescriptreact", ]]
		--[[ 	} ]]
		--[[ for _, v in ipairs(js_fts) do ]]
		--[[ 	if ft == v then ]]
		--[[ 		vim.cmd("EslintFixAll") ]]
		--[[ 		break ]]
		--[[ 	end ]]
		--[[ end ]]
		--[[ 	conform.format({ ]]
		--[[ 		lsp_format = "last", ]]
		--[[ 		async = true, ]]
		--[[ 		quiet = true, ]]
		--[[ 	}) ]]
		--[[ end ]]

		require("conform").setup()

		vim.keymap.set({ "n", "v" }, "<leader>p",
			function()
				local opts = {
					bufnr = 0,
					lsp_format = "fallback",
					async = true,
				}

				if vim.fn.mode() == 'v' then
					local start_pos = vim.fn.getpos("'<")
					local end_pos = vim.fn.getpos("'>")
					opts.range = {
						start = { row = start_pos[2], col = start_pos[3] },
						end_pos = { row = end_pos[2], col = end_pos[3] }
					}
				end

				require("conform").format(opts)
			end,
			{ desc = "Format file or range" })
	end,
}
