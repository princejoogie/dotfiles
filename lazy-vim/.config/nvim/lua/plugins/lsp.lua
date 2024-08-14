return {
  {
    "neovim/nvim-lspconfig",
    opts = function()
      return {
        diagnostics = {
          underline = true,
          update_in_insert = false,
          float = {
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
          },
          virtual_text = false,
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
              [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
              [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
              [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
            },
          },
        },
        inlay_hints = {
          enabled = false,
        },
        codelens = {
          enabled = false,
        },
        document_highlight = {
          enabled = true,
        },
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
        servers = {
          vtsls = {
            settings = {
              typescript = {
                inlayHints = {
                  enumMemberValues = { enabled = false },
                  functionLikeReturnTypes = { enabled = false },
                  parameterNames = { enabled = false },
                  parameterTypes = { enabled = false },
                  propertyDeclarationTypes = { enabled = false },
                  variableTypes = { enabled = false },
                },
              },
            },
          },
        },
        setup = {},
      }
    end,
  },
}
