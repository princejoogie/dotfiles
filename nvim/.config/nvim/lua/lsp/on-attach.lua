local tw_highlight = safe_require("tailwind-highlight")

local M = {}

M.on_attach = function(client, bufnr)
	if tw_highlight then
		tw_highlight.setup(client, bufnr)
	end

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
	keymap(bufnr, "n", "<leader>io", "<cmd>TypescriptOrganizeImports<CR>", opts)
	keymap(bufnr, "n", "<leader>id", "<cmd>TypescriptRemoveUnused<CR>", opts)
	keymap(bufnr, "n", "<leader>ia", "<cmd>TypescriptAddMissingImports<CR>", opts)
	keymap(bufnr, "n", "<leader>gd", "<cmd>TypescriptGoToSourceDefinition<CR>", opts)
end

return M
