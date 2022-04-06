local utils = require("utils")
local keymap = utils.keymap
local bopts = utils.bopts

vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    signs = true,
    underline = true,
    virtual_text = true,
    show_diagnostic_autocmds = {"InsertLeave", "TextChanged"},
    diagnostic_delay = 500
  }
)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = "rounded"})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = "rounded"})

local opts = {noremap = true, silent = true}
local tw_highlight = require("tailwind-highlight")

local on_attach = function(client, bufnr)
  opts.buffer = bufnr
  bopts(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  keymap("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  keymap("n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
  keymap("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
  keymap("n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
  keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)

  tw_highlight.setup(client, bufnr)
end

local lsp_installer = require("nvim-lsp-installer")
local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Gutter Signs
local signs = {Error = " ", Warn = " ", Hint = " ", Info = " "}
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
end

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

vim.diagnostic.config(
  {
    virtual_text = {
      prefix = "●"
    },
    float = {
      border = "rounded"
    },
    severity_sort = true
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

    if server.name == "emmet_ls" then
      lspOpts.filetypes = {"html", "css", "typescriptreact", "javascriptreact"}
    end

    server:setup(lspOpts)
  end
)

local null_ls = require("null-ls")
local ca = null_ls.builtins.code_actions
local diag = null_ls.builtins.diagnostics
local hvr = null_ls.builtins.hover

null_ls.setup(
  {
    sources = {
      -- CODE ACTIONS
      ca.eslint.with({prefer_local = "node_modules/.bin"}),
      ca.gitsigns,
      ca.shellcheck,
      -- DIAGNOSTICS
      diag.cppcheck,
      diag.eslint.with({prefer_local = "node_modules/.bin"}),
      diag.hadolint,
      diag.misspell,
      diag.shellcheck,
      diag.tsc.with({prefer_local = "node_modules/.bin"}),
      -- HOVER
      hvr.dictionary
    },
    should_attach = function(bufnr)
      local filename = vim.api.nvim_buf_get_name(bufnr)
      local will_attach = not string.match(filename, ".env")
      return will_attach
    end
  }
)