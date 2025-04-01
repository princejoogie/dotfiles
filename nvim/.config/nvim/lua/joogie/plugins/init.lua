local cmd = require("joogie.utils").cmd

return {
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",
  "tpope/vim-sleuth",
  "tpope/vim-surround",
  "tpope/vim-repeat",
  "nvim-lua/plenary.nvim",
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    -- stylua: ignore
    keys = {
      { "<leader>wl", function() require("persistence").load() end, desc = "Load Persistence" },
    },
  },
  {
    "stevearc/oil.nvim",
    opts = {
      keymaps = {
        ["H"] = { "actions.toggle_hidden", mode = "n" },
        ["<BS>"] = { "actions.parent", mode = "n" },
      },
    },
    lazy = false,
    keys = {
      { "<leader>oi", cmd("lua require('oil').open()"), desc = "Open Oil" },
    },
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      harpoon:extend({
        UI_CREATE = function(cx)
          -- stylua: ignore start
          vim.keymap.set("n", "<C-v>", function() harpoon.ui:select_menu_item({ vsplit = true }) end, { buffer = cx.bufnr, desc = "Harpoon VSplit" })
          vim.keymap.set("n", "<C-h>", function() harpoon.ui:select_menu_item({ split = true }) end, { buffer = cx.bufnr, desc = "Harpoon Split" })
          vim.keymap.set("n", "<C-t>", function() harpoon.ui:select_menu_item({ tabedit = true }) end, { buffer = cx.bufnr, desc = "Harpoon Tab" })
          -- stylua: ignore end
        end,
      })

      -- stylua: ignore start
      vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon Add" })
      vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon Quick Menu" })

      vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon 1" })
      vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon 2" })
      vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon 3" })
      vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon 4" })
      -- stylua: ignore end
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      local function isRecording()
        local reg = vim.fn.reg_recording()
        if reg == "" then
          return ""
        end
        return "Recording @" .. reg
      end

      local function filepath()
        return vim.fn.expand("%:p:.")
      end

      require("lualine").setup({
        options = {
          theme = "catppuccin",
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { filepath },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { isRecording, "location" },
        },
      })
    end,
  },
  {
    "folke/which-key.nvim",
    lazy = false,
    opts = {
      win = { border = "rounded" },
      preset = "modern",
      icons = {
        mappings = false,
        group = "  ",
      },
    },
    keys = {
      { "<leader>wk", cmd("WhichKey"), desc = "Show which-key" },
    },
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "folke/flash.nvim",
    lazy = true,
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash", },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash", },
    },
  },
  {
    "numToStr/Comment.nvim",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      require("Comment").setup({
        toggler = { line = "<leader>cl", block = "<leader>cc" },
        opleader = { line = "cl", block = "cc" },
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },
  {
    "diepm/vim-rest-console",
    ft = { "rest" },
    config = function()
      vim.g.vrc_response_default_content_type = "application/json"
      vim.g.vrc_output_buffer_name = "__VRC_OUTPUT.json"
      vim.g.vrc_auto_format_response_patterns = {
        json = "jq",
      }
      vim.g.vrc_show_command = true
      vim.g.vrc_trigger = "<leader>S"
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "markdown", "markdown_inline", "Avante", "mcphub" },
    },
    ft = { "markdown", "markdown_inline", "Avante", "mcphub" },
    -- stylua: ignore
    keys = {
      { "<leader>mm", cmd("RenderMarkdown toggle"), desc = "Markview toggle" },
    },
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      vim.g.db_ui_execute_on_save = 0
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_use_nvim_notify = 1
    end,
  },
  {
    "aserowy/tmux.nvim",
    opts = { copy_sync = { enable = false }, resize = { resize_step_x = 5, resize_step_y = 5 } },
    -- stylua: ignore
    keys = {
      { "<C-Left>", cmd("lua require('tmux').resize_left()"), desc = "+ Resize Vertically" },
      { "<C-Down>", cmd("lua require('tmux').resize_bottom()"), desc = "+ Resize Horizontally" },
      { "<C-Up>", cmd("lua require('tmux').resize_top()"), desc = "- Resize Horizontally" },
      { "<C-Right>", cmd("lua require('tmux').resize_right()"), desc = "- Resize Vertically" },
      { "<C-h>", cmd("lua require('tmux').move_left()"), desc = "Move to left pane" },
      { "<C-j>", cmd("lua require('tmux').move_bottom()"), desc = "Move to bottom pane" },
      { "<C-k>", cmd("lua require('tmux').move_top()"), desc = "Move to top pane" },
      { "<C-l>", cmd("lua require('tmux').move_right()"), desc = "Move to right pane" },
    },
  },
  {
    "sotte/presenting.nvim",
    opts = {},
    cmd = { "Presenting" },
    keys = {
      { "<leader>xp", cmd("Presenting"), desc = "Presenting toggle" },
    },
  },
  { "cameron-wags/rainbow_csv.nvim", opts = {}, ft = { "csv" } },
  {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      user_default_options = {
        names = false,
        RGB = true,
        RGBA = true,
        RRGGBB = true,
        RRGGBBAA = true,
        AARRGGBB = true,
      },
    },
  },
}
