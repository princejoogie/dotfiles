local u = require("utils")
local tw_status, tw_highlight = pcall(require, "tailwind-highlight")
local typescript_status, typescript = pcall(require, "typescript")

local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true

local on_attach = function(client, bufnr)
  u.buf_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  u.buf_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
  u.buf_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
  u.buf_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
  u.buf_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
  u.buf_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
  u.buf_keymap(bufnr, "n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
  u.buf_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
  u.buf_keymap(bufnr, "n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>")
  u.buf_keymap(bufnr, "n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>")
  u.buf_keymap(bufnr, "n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>")
  u.buf_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
  u.buf_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")

  if (tw_status) then
    tw_highlight.setup(client, bufnr)
  end

  if (typescript_status and client.name == "tsserver") then
    typescript.setup(
      {
        disable_commands = false,
        debug = false,
        go_to_source_definition = {
          fallback = true
        }
      }
    )

    u.buf_keymap(bufnr, "n", "<leader>rf", "<cmd>:TypescriptRenameFile<CR>")
    u.buf_keymap(bufnr, "n", "<leader>io", "<cmd>:TypescriptOrganizeImports<CR>")
    u.buf_keymap(bufnr, "n", "<leader>id", "<cmd>:TypescriptRemoveUnused<CR>")
    u.buf_keymap(bufnr, "n", "<leader>ia", "<cmd>:TypescriptAddMissingImports<CR>")
    u.buf_keymap(bufnr, "n", "<leader>gd", "<cmd>:TypescriptGoToSourceDefinition<CR>")
  end
end

local lsp_status, lsp_installer = pcall(require, "nvim-lsp-installer")
if (lsp_status) then
  lsp_installer.settings(
    {
      ui = {
        icons = {
          server_installed = "✓",
          server_pending = "➜",
          server_uninstalled = "✗"
        }
      }
    }
  )

  lsp_installer.on_server_ready(
    function(server)
      local lspOpts = {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = {"vim"}
            }
          }
        }
      }

      local schema_status, schema_store = pcall(require, "schemastore")
      if (schema_status) then
        lspOpts.settings.json = {
          schema_store.json.schemas(),
          validate = {enable = true}
        }
      end

      if server.name == "emmet_ls" then
        lspOpts.filetypes = {"html", "css", "typescriptreact", "javascriptreact"}
      end

      server:setup(lspOpts)
    end
  )
end

-- Gutter Signs
local signs = {
  Error = u.icons.Error,
  Warn = u.icons.Warn,
  Hint = u.icons.Hint,
  Info = u.icons.Info
}

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
end

vim.diagnostic.config(
  {
    virtual_text = nil,
    float = {border = "rounded"},
    severity_sort = true
  }
)

local win_status, win = pcall(require, "lspconfig.ui.windows")
if (win_status) then
  local _default_opts = win.default_opts
  win.default_opts = function(options)
    local lopts = _default_opts(options)
    lopts.border = "single"
    return lopts
  end
end

vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    signs = true,
    underline = true,
    virtual_text = false,
    update_in_insert = false,
    diagnostic_delay = 500
  }
)
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = "rounded"})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = "rounded"})
