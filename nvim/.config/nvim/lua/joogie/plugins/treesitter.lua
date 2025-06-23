local cmd = require("joogie.utils").cmd

return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-context",
      opts = { enable = true },
      -- stylua: ignore
      keys = {
        { mode = { "n", "v" }, "<leader>k", function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "Go to context", },
        {"<leader>tc", cmd("TSContext toggle"), desc = "Toggle Treesitter Context"},
      },
    },
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      config = function()
        local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
        local configs = require("nvim-treesitter.configs")
        for name, fn in pairs(move) do
          if name:find("goto") == 1 then
            move[name] = function(q, ...)
              if vim.wo.diff then
                local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
                for key, query in pairs(config or {}) do
                  if q == query and key:find("[%]%[][cC]") then
                    vim.cmd("normal! " .. key)
                    return
                  end
                end
              end
              return fn(q, ...)
            end
          end
        end
      end,
    },
  },
  opts = {
    autotag = {
      enable = true,
      filetypes = {
        "html",
        "javascript",
        "javascriptreact",
        "jsx",
        "markdown",
        "tsx",
        "typescript",
        "typescriptreact",
        "prisma",
      },
    },
    ensure_installed = {
      "css",
      "dockerfile",
      "html",
      "javascript",
      "jsdoc",
      "json",
      "latex",
      "lua",
      "markdown",
      "norg",
      "prisma",
      "python",
      "query",
      "regex",
      "scss",
      "sql",
      "svelte",
      "tsx",
      "typescript",
      "typst",
      "vue",
      "yaml",
    },
    highlight = { enable = true, additional_vim_regex_highlighting = false },
    indent = { enable = true },
    textobjects = {
      move = {
        enable = true,
        goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
        goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
        goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
        goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
      },
    },
  },
  config = function(_, opts)
    if type(opts.ensure_installed) == "table" then
      ---@type table<string, boolean>
      local added = {}
      opts.ensure_installed = vim.tbl_filter(function(lang)
        if added[lang] then
          return false
        end
        added[lang] = true
        return true
      end, opts.ensure_installed)
    end
    require("nvim-treesitter.configs").setup(opts)
  end,
  build = ":TSUpdate",
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  keys = {
    { "<bs>", desc = "Decrement selection", mode = "x" },
  },
}
