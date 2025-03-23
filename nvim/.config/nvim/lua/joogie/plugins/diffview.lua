local utils = require("joogie.utils")
local toggle_diffview = utils.toggle_diffview
local cmd = utils.cmd

return {
  "sindrets/diffview.nvim",
  keys = {
    {
      "<leader>do",
      function()
        local first_branch = nil

        vim.ui.select(utils.git.branches(), {
          prompt = "Select first branch:",
        }, function(branch)
          if not branch then
            return
          end

          first_branch = branch

          vim.ui.select(utils.git.branches(), {
            prompt = "Select second branch:",
          }, function(second_branch)
            if not second_branch then
              return
            end

            if first_branch == "HEAD" and second_branch == "HEAD" then
              return vim.cmd("DiffviewOpen")
            end

            if second_branch == first_branch then
              return vim.notify("Please select different branches", vim.log.levels.ERROR)
            end

            vim.cmd("DiffviewOpen " .. first_branch .. ".." .. second_branch)
          end)
        end)
      end,
      desc = "Diffview: on two branches",
    },
    {
      "<leader>dc",
      function()
        local first_commit = nil

        vim.ui.select(utils.git.commits(), {
          prompt = "Select first commit:",
        }, function(commit)
          if not commit then
            return
          end

          first_commit = vim.split(commit, " ")[1]

          vim.ui.select(utils.git.commits(), {
            prompt = "Select second commit:",
          }, function(second_commit)
            if not second_commit then
              return
            end

            second_commit = vim.split(second_commit, " ")[1]

            if second_commit == first_commit then
              return vim.notify("Please select different commits", vim.log.levels.ERROR)
            end

            vim.cmd("DiffviewOpen " .. first_commit .. ".." .. second_commit)
          end)
        end)
      end,
      desc = "Diffview: on two commits",
    },
    {
      "<leader>dh",
      function()
        toggle_diffview("DiffviewFileHistory")
      end,
      desc = "Diffview: on all commits",
    },
    {
      "<leader>df",
      function()
        toggle_diffview("DiffviewFileHistory %")
      end,
      desc = "Diffview: on current file history",
    },
    { "<leader>dq", cmd("tabc"), desc = "Close Tab" },
  },
}
