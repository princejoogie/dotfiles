return {
  "lewis6991/gitsigns.nvim",
  lazy = false,
  opts = {
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end)

      map("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, { desc = "Navigate to next hunk" })

      -- Actions
      map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage Hunk" })
      map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset Hunk" })

      map("v", "<leader>hs", function()
        gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "Reset Hunk (Visual)" })

      map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Stage Buffer" })
      map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Reset Buffer" })
      map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview Hunk" })
      map("n", "<leader>hi", gitsigns.preview_hunk_inline, { desc = "Preview Hunk Inline" })

      map("n", "<leader>hd", gitsigns.diffthis, { desc = "Diff This" })

      map("n", "<leader>hD", function()
        gitsigns.diffthis("~")
      end, { desc = "Diff This ~" })

      map("n", "<leader>hQ", function()
        gitsigns.setqflist("all")
      end, { desc = "Set Quickfix List (All)" })
      map("n", "<leader>hq", gitsigns.setqflist, { desc = "Set Quickfix List" })

      -- Toggles
      map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Toggle Current Line Blame" })
      map("n", "<leader>td", gitsigns.toggle_deleted, { desc = "Toggle Deleted" })
      map("n", "<leader>tw", gitsigns.toggle_word_diff, { desc = "Toggle Word Diff" })

      -- Text object
      map({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "inner Hunk" })
    end,
  },
  keys = {
    { "<leader>h", function() end, desc = "Gitsigns" },
    { "<leader>t", function() end, desc = "Toggle" },
  },
}
