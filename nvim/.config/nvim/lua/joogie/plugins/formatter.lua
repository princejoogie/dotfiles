local find_git_root = require("joogie.utils").find_git_root

local is_biome_present = vim.uv.fs_stat(find_git_root() .. "/biome.json") and true or false

return {
  "stevearc/conform.nvim",
  opts = {},
  config = function()
    local conform = require("conform")
    local util = require("conform.util")

    conform.setup({
      formatters_by_ft = {
        cpp = { "clang-format" },
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettier", "eslint_d", "biome" },
        typescript = { "prettier", "eslint_d", "biome" },
        javascriptreact = { "prettier", "eslint_d", "biome" },
        typescriptreact = { "prettier", "eslint_d", "biome" },
        svelte = { "prettier" },
        css = { "prettier", "biome" },
        html = { "prettier", "biome" },
        json = { "prettier", "biome" },
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
        prettier = {
          command = util.from_node_modules(fs.is_windows and "prettier.cmd" or "prettier"),
          args = function(self, ctx)
            return eval_parser(self, ctx) or { "--stdin-filepath", "$FILENAME" }
          end,
          range_args = function(self, ctx)
            local start_offset, end_offset = util.get_offsets_from_range(ctx.buf, ctx.range)
            local args = eval_parser(self, ctx) or { "--stdin-filepath", "$FILENAME" }
            return vim.list_extend(args, { "--range-start=" .. start_offset, "--range-end=" .. end_offset })
          end,
          condition = function()
            return not is_biome_present
          end,
        },
        eslint_d = {
          command = util.from_node_modules("eslint_d"),
          args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "$FILENAME" },
          condition = function()
            return not is_biome_present
          end,
        },
        biome = {
          command = util.from_node_modules("biome"),
          stdin = true,
          args = { "check", "--write", "--stdin-file-path", "$FILENAME" },
          condition = function()
            return is_biome_present
          end,
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
