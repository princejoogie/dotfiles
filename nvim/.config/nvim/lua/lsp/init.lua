local mason_status, mason = pcall(require, "mason")

if not mason_status then
  return
end

mason.setup({ui = {border = "rounded"}})

local m_status, m = pcall(require, "mason-lspconfig")

if not m_status then
  return
end

local lsp_status, lspconfig = pcall(require, "lspconfig")

if not lsp_status then
  return
end

m.setup(
  {
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
      "graphql"
    }
  }
)

require("lsp.config")

local cmp_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

if not cmp_lsp_status then
  return
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

local opts = {
  capabilities = capabilities,
  on_attach = require("lsp.on-attach").on_attach
}

local ts_status, typescript = pcall(require, "typescript")

if not ts_status then
  return
end

m.setup_handlers(
  {
    function(server_name)
      local has_custom_opts, custom_opts = pcall(require, "lsp.settings." .. server_name)

      if has_custom_opts then
        opts = vim.tbl_deep_extend("force", custom_opts, opts)
      end

      lspconfig[server_name].setup(opts)
    end,
    ["tsserver"] = function()
      typescript.setup({server = opts})
    end
  }
)
