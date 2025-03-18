local cmd = require("joogie.utils").cmd
local exclude = require("joogie.utils").exclude

return {
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",
  "tpope/vim-sleuth",
  "tpope/vim-surround",
  "tpope/vim-repeat",
  "nvim-lua/plenary.nvim",
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      -- stylua: ignore start
      { "<leader>bd", function() Snacks.bufdelete.delete() end, desc = "Delete current buffer", },
      { "<leader>ba", function() Snacks.bufdelete({ filter = function(buf) return #vim.fn.win_findbuf(buf) == 0 end, }) end, desc = "Delete all hidden buffers", },
      { "<leader>zm", function() Snacks.zen.zen() end, desc = "Open Explorer", },
      -- Top Pickers & Explorer
      { "<C-b>", function() Snacks.explorer.open({ hidden = true, ignored = true, exclude = exclude }) end, desc = "Open Explorer", },
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
      dashboard = { enabled = true },
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
      zen = { enabled = true, dim = false },
      picker = {
        enabled = true,
        ui_select = true,
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  ["z"] = "explorer_close_all",
                  ["]c"] = "explorer_git_next",
                  ["[c"] = "explorer_git_prev",
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
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        transparent = true,
        plugins = { all = true },
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
          functions = {},
          variables = {},
          sidebars = "transparent",
          floats = "transparent",
        },
        on_highlights = function(hl)
          local git = {
            delete = { bg = "#151B23", fg = "#151B23" },
            add = { bg = "#14261F" },
            change = { bg = "#26181C" },
            text = { bg = "#1F572D" },
          }

          hl.Folded = hl.Comment
          hl.TreesitterContext = { bg = hl.CursorLine.bg }
          hl.Visual = { bg = hl.CursorLine.bg }

          hl.DiffAdd = git.add
          hl.DiffChange = git.change
          hl.DiffDelete = git.delete
          hl.DiffText = git.text

          hl.diffAdded = git.add
          hl.diffChanged = git.change
          hl.diffRemoved = { bg = git.delete.bg }
          hl.diffLine = git.text
        end,
      })
      vim.cmd([[colorscheme tokyonight-night]])
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

      vim.keymap.set("n", "<leader>P", function() harpoon:list():prev() end)
      vim.keymap.set("n", "<leader>N", function() harpoon:list():next() end)
      -- stylua: ignore end
    end,
  },
  { "nvim-lualine/lualine.nvim", opts = { theme = "tokyonight" } },
  {
    "sindrets/diffview.nvim",
    keys = {
      { "<leader>do", ":DiffviewOpen", desc = "Diff View Open" },
      { "<leader>dh", cmd("DiffviewFileHistory"), desc = "Diff View File History" },
      { "<leader>dq", cmd("tabc"), desc = "Close Tab" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = { win = { border = "rounded" } },
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
        toggler = { line = "<leader>cl", block = "<leader>bl" },
        opleader = { line = "<leader>cc", block = "<leader>cb" },
        pre_hook = function(ctx)
          local U = require("Comment.utils")

          local location = nil
          if ctx.ctype == U.ctype.block then
            location = require("ts_context_commentstring.utils").get_cursor_location()
          elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
            location = require("ts_context_commentstring.utils").get_visual_start_location()
          end

          return require("ts_context_commentstring.internal").calculate_commentstring({
            key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
            location = location,
          })
        end,
      })
    end,
  },
  {
    "diepm/vim-rest-console",
    config = function()
      vim.g.vrc_response_default_content_type = "application/json"
      vim.g.vrc_output_buffer_name = "__VRC_OUTPUT.json"
      vim.g.vrc_auto_format_response_patterns = {
        json = "jq",
      }
      vim.g.vrc_show_command = true
      vim.g.vrc_trigger = "<leader><CR>"
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    -- stylua: ignore
    keys = {
      { "<leader>mm", cmd("Markview Toggle"), desc = "Markview toggle" },
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
  { "cameron-wags/rainbow_csv.nvim", opts = {} },
}
