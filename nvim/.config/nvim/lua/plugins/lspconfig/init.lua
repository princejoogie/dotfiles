local setupConfig = function()
	local icons = {
		Error = " ",
		Warn = " ",
		Hint = " ",
		Info = " ",
	}

	local signs = {
		{ name = "DiagnosticSignError", text = icons.Error },
		{ name = "DiagnosticSignWarn", text = icons.Warn },
		{ name = "DiagnosticSignInfo", text = icons.Info },
		{ name = "DiagnosticSignHint", text = icons.Hint },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end

	local config = {
		virtual_text = false,
		signs = { active = signs },
		update_in_insert = false,
		underline = true,
		severity_sort = true,
		float = {
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	}

	vim.diagnostic.config(config)

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
	vim.lsp.handlers["textDocument/signatureHelp"] =
		vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
end

local on_attach = function(client, bufnr)
	require("tailwind-highlight").setup(client, bufnr)

	local opts = { noremap = true, silent = true }
	local keymap = vim.api.nvim_buf_set_keymap

	keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	keymap(bufnr, "n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
	keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	--[[ keymap(bufnr, "n", "gf", "<cmd>lua vim.lsp.buf.format()<CR>", opts) ]]
	keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	keymap(bufnr, "n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	keymap(bufnr, "n", "<leader>dk", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
	keymap(bufnr, "n", "<leader>dj", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
	keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
end

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "williamboman/mason.nvim", build = ":MasonUpdate" },
		{ "j-hui/fidget.nvim", opts = {} },
		{
			"utilyre/barbecue.nvim",
			dependencies = {
				"SmiteshP/nvim-navic",
				"nvim-tree/nvim-web-devicons",
			},
			config = function()
				require("barbecue").setup()
			end,
		},
		{
			"simrat39/symbols-outline.nvim",
			config = function()
				require("symbols-outline").setup({ width = 15, show_symbol_details = false })
			end,
		},
		"williamboman/mason-lspconfig.nvim",
		"davidosomething/format-ts-errors.nvim",
		"princejoogie/tailwind-highlight.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"b0o/schemastore.nvim",
		"folke/neodev.nvim",
	},
	config = function()
		local mlsp = require("mason-lspconfig")
		local lspconfig = require("lspconfig")

		require("mason").setup()

		mlsp.setup({
			ensure_installed = {
				"astro",
				"bashls",
				"cssls",
				"cssmodules_ls",
				"dockerls",
				"emmet_ls",
				"eslint",
				"graphql",
				"html",
				"jsonls",
				"lua_ls",
				"prismals",
				"pylsp",
				"pyright",
				"tailwindcss",
				"tsserver",
				"yamlls",
			},
		})

		setupConfig()

		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local capabilities = cmp_nvim_lsp.default_capabilities()

		local opts = {
			capabilities = capabilities,
			on_attach = on_attach,
		}

		mlsp.setup_handlers({
			function(server_name)
				local custom_opts_status, custom_opts = pcall(require, "plugins.lspconfig.settings." .. server_name)

				if custom_opts_status then
					opts = vim.tbl_deep_extend("force", custom_opts, opts)
				end

				lspconfig[server_name].setup(opts)
			end,
			["tsserver"] = function()
				lspconfig.tsserver.setup({
					capabilities = opts.capabilities,
					on_attach = opts.on_attach,
					handlers = {
						["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
							if result.diagnostics == nil then
								return
							end

							local idx = 1

							while idx <= #result.diagnostics do
								local entry = result.diagnostics[idx]
								local formatter = require("format-ts-errors")[entry.code]
								entry.message = formatter and formatter(entry.message) or entry.message
								if entry.code == 80001 then
									table.remove(result.diagnostics, idx)
								else
									idx = idx + 1
								end
							end
							vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
						end,
					},
				})
			end,
		})
	end,
}
