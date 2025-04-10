local setupConfig = function()
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

  local config = {
    virtual_text = false,
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
end

local on_attach_extras = {}

local on_attach = function(client, bufnr)
  local attach_func = on_attach_extras[client.name]
  if attach_func then
    attach_func(client, bufnr)
  end

  local nmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end

    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end

  nmap("K", "<cmd>lua vim.lsp.buf.hover()<CR>", "Hover Action")
  nmap("<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename symbol")
  nmap("<leader>ca", "<cmd>lua vim.lsp.buf.code_action({ apply = true })<CR>", "Code actions")
  nmap("<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", "Open float")
  nmap("[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", "Previous Error")
  nmap("]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", "Next Error")
  nmap("<leader>dk", '<cmd>lua vim.notify("use [d")<CR>', "Previous Error")
  nmap("<leader>dj", '<cmd>lua vim.notify("use ]d")<CR>', "Next Error")
end

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "j-hui/fidget.nvim",
    },
    config = function()
      local mlsp = require("mason-lspconfig")
      local lspconfig = require("lspconfig")

      require("lspconfig.ui.windows").default_options.border = "rounded"
      require("mason").setup({ ui = { border = "rounded" } })

      mlsp.setup({
        ensure_installed = {
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

      setupConfig()

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      local opts = {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      mlsp.setup_handlers({
        function(server_name)
          local custom_opts_status, custom_opts = pcall(require, "joogie.plugins.lsp." .. server_name)

          if custom_opts_status then
            opts = vim.tbl_deep_extend("force", custom_opts, opts)
          end

          lspconfig[server_name].setup(opts)
        end,
      })
    end,
  },
}
