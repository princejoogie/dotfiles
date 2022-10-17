local mason = safe_require("mason")

if not mason then
	return
end

mason.setup({ ui = { border = "rounded" } })

local m = safe_require("mason-lspconfig")

if not m then
	return
end

local lspconfig = safe_require("lspconfig")

if not lspconfig then
	return
end

m.setup({
	ensure_installed = {
		"sumneko_lua",
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

m.setup_handlers({
	function(server_name)
		local custom_opts_status, custom_opts = pcall(require, "lsp.settings." .. server_name)

		if custom_opts_status then
			opts = vim.tbl_deep_extend("force", custom_opts, opts)
		end

		lspconfig[server_name].setup(opts)
	end,
	["tsserver"] = function()
		typescript.setup({ server = opts })
	end,
})
