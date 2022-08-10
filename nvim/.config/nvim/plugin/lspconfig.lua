local utils = require("utils")
local keymap = utils.keymap
local bopts = utils.bopts
local icons = utils.icons

vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    signs = true,
    underline = true,
    virtual_text = false,
    -- show_diagnostic_autocmds = {"InsertLeave", "TextChanged"},
    update_in_insert = false,
    diagnostic_delay = 500
  }
)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = "rounded"})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = "rounded"})

local opts = {noremap = true, silent = true}
local tw_highlight = require("tailwind-highlight")
require("lsp_signature").setup(
  {
    debug = false,
    log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log",
    verbose = false,
    bind = true,
    doc_lines = 0,
    floating_window = true,
    floating_window_above_cur_line = true,
    floating_window_off_x = -1,
    floating_window_off_y = -1,
    fix_pos = false,
    hint_enable = false,
    hint_prefix = "🐼 ",
    hint_scheme = "String",
    hi_parameter = "LspSignatureActiveParameter",
    max_height = 12,
    max_width = 80,
    handler_opts = {border = "rounded"},
    always_trigger = false,
    auto_close_after = 3,
    extra_trigger_chars = {},
    zindex = 200,
    padding = "",
    transparency = nil,
    timer_interval = 200,
    toggle_key = "<M-x>"
  }
)

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
local signs = {Error = icons.Error, Warn = icons.Warn, Hint = icons.Hint, Info = icons.Info}
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
    -- virtual_text = {
    --   prefix = "●"
    -- },
    virtual_text = nil,
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
        json = {schemas = require("schemastore").json.schemas()},
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

local win = require("lspconfig.ui.windows")
local _default_opts = win.default_opts

win.default_opts = function(options)
  local lopts = _default_opts(options)
  lopts.border = "single"
  return lopts
end

-- Slows down nvim on big projects
--[[
   [ local null_ls = require("null-ls")
   [ local ca = null_ls.builtins.code_actions
   [ local diag = null_ls.builtins.diagnostics
   [ local hvr = null_ls.builtins.hover
   [
   [ null_ls.setup(
   [   {
   [     sources = {
   [       -- CODE ACTIONS
   [       ca.eslint.with({prefer_local = "node_modules/.bin"}),
   [       ca.gitsigns,
   [       ca.shellcheck,
   [       -- DIAGNOSTICS
   [       diag.cppcheck,
   [       diag.eslint.with({prefer_local = "node_modules/.bin"}),
   [       diag.hadolint,
   [       diag.misspell,
   [       diag.shellcheck,
   [       -- diag.tsc.with({prefer_local = "node_modules/.bin"}),
   [       -- HOVER
   [       hvr.dictionary
   [     },
   [     should_attach = function(bufnr)
   [       local filename = vim.api.nvim_buf_get_name(bufnr)
   [       local will_attach = not string.match(filename, ".env")
   [       return will_attach
   [     end
   [   }
   [ )
   ]]
