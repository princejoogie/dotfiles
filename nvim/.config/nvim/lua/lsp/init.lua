local mason = safe_require("mason")

if not mason then
	return
end

mason.setup({ ui = { border = "rounded" } })

local mlsp = safe_require("mason-lspconfig")

if not mlsp then
	return
end

local lspconfig = safe_require("lspconfig")

if not lspconfig then
	return
end

mlsp.setup({
	ensure_installed = {
		"lua_ls",
		"emmet_ls",
		"html",
		"astro",
		"cssmodules_ls",
		"cssls",
		"tailwindcss",
		"bashls",
		"yamlls",
		"dockerls",
		"prismals",
		"jsonls",
		"tsserver",
		"eslint",
		"graphql",
	},
})

require("lsp.config")

local cmp_nvim_lsp = safe_require("cmp_nvim_lsp")

if not cmp_nvim_lsp then
	return
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

local opts = {
	capabilities = capabilities,
	on_attach = require("lsp.on-attach").on_attach,
}

local typescript = safe_require("typescript")

if not typescript then
	return
end

mlsp.setup_handlers({
	function(server_name)
		local custom_opts_status, custom_opts = pcall(require, "lsp.settings." .. server_name)

		if custom_opts_status then
			opts = vim.tbl_deep_extend("force", custom_opts, opts)
		end

		lspconfig[server_name].setup(opts)
	end,
	["tsserver"] = function()
		typescript.setup({ server = opts })
		lspconfig.tsserver.setup({
			handlers = {
				["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
					if result.diagnostics == nil then
						return
					end
					-- ignore some tsserver diagnostics
					local idx = 1

					while idx <= #result.diagnostics do
						local entry = result.diagnostics[idx]
						local formatter = require("format-ts-errors")[entry.code]
						entry.message = formatter and formatter(entry.message) or entry.message
						-- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
						if entry.code == 80001 then
							-- { message = "File is a CommonJS module; it may be converted to an ES module.", }
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
