local u = require("utils")

local signs = {
	{ name = "DiagnosticSignError", text = u.icons.Error },
	{ name = "DiagnosticSignWarn", text = u.icons.Warn },
	{ name = "DiagnosticSignInfo", text = u.icons.Info },
	{ name = "DiagnosticSignHint", text = u.icons.Hint },
}

for _, sign in ipairs(signs) do
	vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

local config = {
	virtual_text = false,
	signs = {
		active = signs,
	},
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

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
