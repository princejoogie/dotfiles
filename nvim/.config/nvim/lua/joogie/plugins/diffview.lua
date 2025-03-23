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
          if not branch then
            return
          end

          first_branch = branch

          vim.ui.select(utils.git.branches(), {
            prompt = "Select second branch:",
          }, function(branch2)
            if not branch2 then
              return
            end

            second_branch = branch2
            vim.notify("Diff view on " .. first_branch .. " and " .. second_branch)
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
        local second_commit = nil

        vim.ui.select(utils.git.commits(), {
          prompt = "Select first commit:",
        }, function(commit)
          if not commit then
            return
          end

          first_commit = vim.split(commit, " ")[1]

          vim.ui.select(utils.git.commits(), {
            prompt = "Select second commit:",
          }, function(commit2)
            if not commit2 then
              return
            end

            second_commit = vim.split(commit2, " ")[1]
            vim.notify("Diff view on " .. first_commit .. " and " .. second_commit)
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
