local exclude = require("joogie.utils").exclude
local utils = require("joogie.utils")

local cmd = utils.cmd
local dashboard_header = utils.dashboard_header

return {
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",
  "tpope/vim-sleuth",
  "tpope/vim-surround",
  "tpope/vim-repeat",
  "nvim-lua/plenary.nvim",
  {
    "folke/snacks.nvim",
    dependencies = {
      {
        "s1n7ax/nvim-window-picker",
        name = "window-picker",
        event = "VeryLazy",
        opts = {
          hint = "floating-big-letter",
          show_prompt = false,
          filter_rules = {
            autoselect_one = true,
            include_current_win = false,
            include_unfocusable_windows = false,
            -- stylua: ignore
            bo = {
              filetype = { "snacks_picker_input", "snacks_picker_list", "NvimTree", "neo-tree", "notify", "snacks_notif", },
              buftype = { "terminal", "nofile", "quickfix", "help", "prompt", "notify", "float" },
            },
          },
        },
      },
    },
    priority = 1000,
    lazy = false,
    keys = {
      -- stylua: ignore start
      { "<M-d>", function() Snacks.words.jump(1, true) end, desc = "Jump to word", },
      { "<leader>bd", function() Snacks.bufdelete.delete() end, desc = "Delete current buffer", },
      { "<leader>ba", function() Snacks.bufdelete({ filter = function(buf) return #vim.fn.win_findbuf(buf) == 0 end, }) end, desc = "Delete all hidden buffers", },
      { "<leader>zm", function() Snacks.zen.zen() end, desc = "Open Explorer", },
      -- Top Pickers & Explorer
      { "<C-b>", function() Snacks.explorer.open({ hidden = true, ignored = false }) end, desc = "Open Explorer", },
      { "<C-p>", function() Snacks.picker.files({ hidden = true, ignored = true, exclude = exclude }) end, desc = "Find Files", },
      { "<C-f>", function() Snacks.picker.grep({ hidden = true, ignored = true, exclude = exclude }) end, desc = "Grep", },
      { "<leader>/", function() Snacks.picker.lines() end, desc = "Grep current buffer", },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History", },
      { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History", },
      { "<leader>sp", function() Snacks.picker() end, desc = "Open Picker", },
      -- git
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches", },
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log", },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status", },
      { "<leader>go", function() Snacks.gitbrowse() end, desc = "Git Repo in Browser", mode = { "n", "v" } },
      { "<leader>gk", function() Snacks.git.blame_line() end, desc = "Git Blame Line", },
      -- search
      { "<leader>s/", function() Snacks.picker.search_history() end, desc = "Search History", },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics", },
      { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics", },
      { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages", },
      { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights", },
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons", },
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps", },
      { "<leader>sr", function() Snacks.picker.resume() end, desc = "Resume", },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History", },
      { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes", },
      { "<leader>?", function() Snacks.picker.spelling() end, desc = "Spelling" },
      -- LSP
      { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", },
      { "gD", function() vim.cmd("vsplit") Snacks.picker.lsp_definitions() end, desc = "Goto Definition in split", },
      { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References", },
      { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation", },
      { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition", },
      { "<leader>ds", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols", },
      { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols", },
      -- stylua: ignore end
      {
        "<leader>gy",
        function()
          Snacks.gitbrowse({
            notify = false,
            open = function(url)
              Snacks.notifier("Permalink copied to clipboard")
              vim.fn.setreg("+", url)
            end,
          })
        end,
        desc = "Copy Git Permalink",
        mode = { "n", "v" },
      },
    },
    opts = {
      bigfile = { enabled = true },
      bufdelete = { enabled = true },
      explorer = { enabled = true },
      git = { enabled = true },
      gitbrowse = { enabled = true },
      image = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      statuscolumn = { enabled = true },
      toggle = { enabled = true },
      words = { enabled = true },
      zen = { enabled = true, toggles = { dim = false } },
      dashboard = {
        enabled = true,
        preset = {
          keys = { { icon = " ", key = "q", desc = "Quit", action = ":qa" } },
          header = dashboard_header,
        },
      },
      picker = {
        enabled = true,
        ui_select = true,
        sources = {
          explorer = {
            actions = {
              window_picker = function(_, item)
                if item.dir then
                  return
                end

                local window_id = require("window-picker").pick_window()

                if not window_id then
                  return
                end

                vim.api.nvim_set_current_win(window_id)
                vim.cmd("edit " .. item._path)
              end,
            },
            win = {
              list = {
                keys = {
                  ["z"] = "explorer_close_all",
                  ["]c"] = "explorer_git_next",
                  ["[c"] = "explorer_git_prev",
                  ["w"] = "window_picker",
                },
              },
            },
          },
        },
        previewers = {
          diff = { builtin = false, cmd = { "delta" } },
          git = { builtin = false, args = {} },
        },
        win = {
          input = {
            keys = {
              ["<a-H>"] = { "toggle_hidden", mode = { "i", "n" } },
              ["<a-M>"] = { "toggle_maximize", mode = { "i", "n" } },
            },
          },
        },
      },
      notifier = {
        enabled = true,
        filter = function(n)
          local banned_messages = {
            "Neo-tree",
            "No information available",
            "Toggling hidden files",
            "Failed to attach to",
            "No items, skipping",
            "Config Change Detected",
            "Executing query",
            "Done after",
          }

          for _, banned in ipairs(banned_messages) do
            if string.find(n.msg, banned, 1, true) then
              return false
            end
          end

          return true
        end,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          vim.ui.input = Snacks.input.input
          vim.ui.select = Snacks.picker.select

          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle.indent():map("<leader>ug")
        end,
      })
    end,
  },
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
          vim.keymap.set("n", "<C-v>", function() harpoon.ui:select_menu_item({ vsplit = true }) end, { buffer = cx.bufnr })
          vim.keymap.set("n", "<C-h>", function() harpoon.ui:select_menu_item({ split = true }) end, { buffer = cx.bufnr })
          vim.keymap.set("n", "<C-t>", function() harpoon.ui:select_menu_item({ tabedit = true }) end, { buffer = cx.bufnr })
          -- stylua: ignore end
        end,
      })

      -- stylua: ignore start
      vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end)
      vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

      vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
      vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
      vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
      vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
      -- stylua: ignore end
    end,
  },
  { "nvim-lualine/lualine.nvim", opts = { options = { theme = "catppuccin" } } },
  {
    "folke/which-key.nvim",
    lazy = false,
    opts = { win = { border = "rounded" }, preset = "modern" },
    -- stylua: ignore
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
        tailwind = true,
      },
    },
  },
}
