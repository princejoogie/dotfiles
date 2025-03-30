local utils = require("joogie.utils")
local exclude = utils.exclude
local dashboard_header = utils.dashboard_header

return {
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
      scope = { enabled = false },
      bigfile = { enabled = true },
      bufdelete = { enabled = true },
      explorer = { enabled = true },
      git = { enabled = true },
      gitbrowse = { enabled = true },
      image = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      quickfile = { enabled = true },
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
        layout = { preset = "vertical" },
        enabled = true,
        ui_select = true,
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
        sources = {
          explorer = {
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
              ["<M-/>"] = { "focus_list", mode = { "i", "n" } },
              ["<a-H>"] = { "toggle_hidden", mode = { "i", "n" } },
              ["<a-M>"] = { "toggle_maximize", mode = { "i", "n" } },
            },
          },
          list = {
            keys = {
              ["<M-/>"] = { "focus_preview", mode = { "i", "n" } },
            },
          },
          preview = {
            keys = {
              ["<M-/>"] = { "focus_input", mode = { "i", "n" } },
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
            '^".*" %d+L, %d+B written$',
          }

          for _, banned in ipairs(banned_messages) do
            if string.find(n.msg, banned) then
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
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      cmdline = { enabled = true },
      messages = { enabled = true },
      popupmenu = { enabled = true },
      notify = { enabled = false },
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
  },
}
