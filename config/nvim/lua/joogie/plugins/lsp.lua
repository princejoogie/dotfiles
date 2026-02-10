---@param client vim.lsp.Client
---@param method vim.lsp.protocol.Method
---@param bufnr? integer some lsp support methods only in specific files
---@return boolean
---@diagnostic disable-next-line: unused-local, unused-function
local function client_supports_method(client, method, bufnr)
  if vim.fn.has("nvim-0.11") == 1 then
    return client:supports_method(method, bufnr)
  else
    ---@diagnostic disable-next-line: param-type-mismatch
    return client.supports_method(method, { bufnr = bufnr })
  end
end

local setup_defaults = function()
  local icons = require("joogie.utils").icons

  local signs = {
    { name = "DiagnosticSignError", text = icons.Error },
    { name = "DiagnosticSignWarn", text = icons.Warn },
    { name = "DiagnosticSignInfo", text = icons.Info },
    { name = "DiagnosticSignHint", text = icons.Hint },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  vim.diagnostic.config({
    virtual_text = false,
    -- virtual_lines = true,
    float = { border = "rounded" },
  })
end

local setup_autocmds = function()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("joogie-lsp-attach", { clear = true }),
    callback = function(event)
      -- local client = vim.lsp.get_client_by_id(event.data.client_id)
      local map = function(keys, func, desc, mode)
        mode = mode or "n"
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
      end

      map("K", vim.lsp.buf.hover, "Hover Action")
      map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
      map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ctions", { "n", "x" })
      map("<leader>e", vim.diagnostic.open_float, "Open float")
      map("[d", function()
        vim.diagnostic.jump({ count = -1, float = true })
      end, "[D]iagnostic Prev")
      map("]d", function()
        vim.diagnostic.jump({ count = 1, float = true })
      end, "[D]iagnostic Next")
    end,
  })
end

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "j-hui/fidget.nvim",
    },
    config = function()
      setup_autocmds()
      setup_defaults()

      local mlsp = require("mason-lspconfig")

      require("lspconfig.ui.windows").default_options.border = "rounded"
      require("mason").setup({ ui = { border = "rounded" } })

      mlsp.setup({
        automatic_enable = true,
        ensure_installed = {
          "biome",
          "bashls",
          "cssls",
          "dockerls",
          "eslint",
          "html",
          "jsonls",
          "lua_ls",
          "prismals",
          "tailwindcss",
          "ts_ls",
          "yamlls",
        },
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
      vim.lsp.config("*", { capabilities = capabilities })
    end,
  },
}
