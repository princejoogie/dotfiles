return {
  "stevearc/conform.nvim",
  opts = {},
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        cpp = { "clang-format" },
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettier", "eslint_d" },
        typescript = { "prettier", "eslint_d" },
        javascriptreact = { "prettier", "eslint_d" },
        typescriptreact = { "prettier", "eslint_d" },
        svelte = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        sql = { "sqlfmt" },
        nix = { "nixpkgs-fmt" },
        zsh = { "shfmt" },
        sh = { "shfmt" },
      },
      formatters = {
        shfmt = {
          args = { "-i", "2", "-filename", "$FILENAME" },
        },
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>p", function()
      local opts = {
        bufnr = 0,
        lsp_format = "fallback",
        async = true,
      }

      if vim.fn.mode() == "v" then
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        opts.range = {
          start = { row = start_pos[2], col = start_pos[3] },
          end_pos = { row = end_pos[2], col = end_pos[3] },
        }
      end

      conform.format(opts)
    end, { desc = "Format file or range" })
  end,
}
