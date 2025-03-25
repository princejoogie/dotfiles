local Util = require("joogie.utils")

local find_git_root = Util.find_git_root
local cmd = Util.cmd

return {
  {
    "joshuavial/aider.nvim",
    config = function()
      require("aider").setup({
        auto_manage_context = false,
        default_bindings = false,
        debug = false,
      })
    end,
    init = function()
      vim.api.nvim_create_autocmd({ "TermOpen", "TermClose" }, {
        group = vim.api.nvim_create_augroup("joogi_aider_console", { clear = true }),
        pattern = "term://*aider*",
        callback = function(ev)
          vim.api.nvim_buf_set_option(ev.buf, "buflisted", false)
          if ev.event == "TermOpen" then
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.signcolumn = "no"
            vim.api.nvim_feedkeys("i", "n", false)
          else
            local enter_key = vim.api.nvim_replace_termcodes("<CR>", true, true, true)
            vim.api.nvim_feedkeys(enter_key, "n", false)
          end
        end,
      })
    end,
    keys = {
      { "<leader>ai", cmd("AiderOpen"), desc = "Aider toggle" },
      { "JJ", "<C-\\><C-n>", mode = { "t", "i" }, desc = "Return to normal mode" },
      { "jj", "<Esc>", mode = { "t", "i" }, desc = "Trigger normal mode in aider" },
      {
        "@@",
        function()
          local aider_buf = vim.api.nvim_get_current_win()
          Snacks.picker({
            finder = "files",
            format = "file",
            focus = "input",
            show_empty = true,
            hidden = false,
            ignored = false,
            follow = false,
            supports_live = true,
            confirm = function(picker, item)
              local git_root = find_git_root()
              local path = item._path:gsub(git_root .. "/", "")

              vim.fn.setreg("+", path .. " ")
              vim.api.nvim_set_current_win(aider_buf)
              vim.api.nvim_feedkeys("p", "t", true)
              vim.api.nvim_feedkeys("i", "n", true)

              Snacks.picker.actions.close(picker)
            end,
          })
        end,
        mode = { "t", "i" },
        desc = "Open Snacks picker and choose file",
      },
    },
  },
}
