local utils = require("joogie.utils")
local toggle_diffview = utils.toggle_diffview
local cmd = utils.cmd

return {
  "sindrets/diffview.nvim",
  keys = {
    {
      "<leader>dw",
      function()
        local first_branch = nil
        local second_branch = nil

        vim.ui.select(utils.git.branches(), {
          prompt = "Select first branch:",
        }, function(branch)
          first_branch = branch

          vim.ui.select(utils.git.branches(), {
            prompt = "Select second branch:",
          }, function(branch2)
            second_branch = branch2

            if not first_branch or not second_branch then
              return vim.notify("Please select two branches", vim.log.levels.ERROR)
            end

            local command = "DiffviewOpen " .. first_branch .. ".." .. second_branch
            vim.cmd(command)
          end)
        end)
      end,
      desc = "Diffview: on two branches",
    },
    {
      "<leader>dc",
      function()
        local first_commit = nil
        local second_commit = nil

        vim.ui.select(utils.git.commits(), {
          prompt = "Select first commit:",
        }, function(commit)
          first_commit = vim.split(commit, " ")[1]

          vim.ui.select(utils.git.commits(), {
            prompt = "Select second commit:",
          }, function(commit2)
            second_commit = vim.split(commit2, " ")[1]

            if not first_commit or not second_commit then
              return vim.notify("Please select two commits", vim.log.levels.ERROR)
            end

            vim.cmd("DiffviewOpen " .. first_commit .. ".." .. second_commit)
          end)
        end)
      end,
      desc = "Diffview: on two commits",
    },
    {
      "<leader>do",
      function()
        vim.ui.select(utils.git.branches(), {
          prompt = "Select branch to diff on:",
        }, function(branch)
          if not branch then
            return
          end

          if branch == "NONE" then
            vim.cmd("DiffviewOpen")
            return
          end

          vim.cmd("DiffviewOpen " .. branch)
        end)
      end,
      desc = "Diffview: on branch",
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
