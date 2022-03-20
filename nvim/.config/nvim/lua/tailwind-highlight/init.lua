local M = {}

local document_colors = require('tailwind-highlight.document-colors')

--- Highlights tailwind color classes
---
-- @param client - client of nvim lsp
-- @param bufnr - bufnr of nvim lsp
-- @param opts - options for tailwind highlight
--
-- @example
-- ```lua
-- local tw_highlight = require('tailwind-highlight')
-- local on_attach = function(client, bufnr)
--   -- ...rest of your code...
--   tw_highlight.setup(client, bufnr, {
--     single_column = false,
--     debounce = 200,
--   })
-- end
-- ```
function M.setup(client, bufnr, opts)
	opts = opts or {}
  if client.server_capabilities.colorProvider then
    document_colors.buf_attach(bufnr, {
			single_column = opts.single_column or false,
			debounce = opts.debounce or 200,
		})
  end
end

return M
