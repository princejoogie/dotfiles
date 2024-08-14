return {
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss All Notifications",
      },
    },
    opts = {
      stages = "static",
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
    init = function()
      local notify = require("notify")
      -- when noice is not enabled, install notify on VeryLazy
      if not LazyVim.has("noice.nvim") then
        LazyVim.on_very_lazy(function()
          local banned_messages = {
            "Neo-tree",
            "No information available",
            "Toggling hidden files",
            "Failed to attach to",
            "No items, skipping",
            "Config Change Detected",
          }

          vim.notify = function(msg, ...)
            for _, banned in ipairs(banned_messages) do
              if string.find(msg, banned, 1, true) then
                return
              end
            end
            return notify(msg, ...)
          end
        end)
      end
    end,
  },
}
