local cmd_notif = function(cmd)
  Snacks.notifier(cmd)
  vim.cmd(cmd)
end

return {
  {
    "GeorgesAlkhouri/nvim-aider",
    cmd = {
      "AiderTerminalToggle",
      "AiderHealth",
    },
    dependencies = { "folke/snacks.nvim" },
    config = function()
      require("nvim_aider").setup({
        picker_cfg = { preset = "vscode" },
        config = {
          os = { editPreset = "nvim-remote" },
          gui = { nerdFontsVersion = "3" },
        },
        win = {
          wo = { winbar = "Aider" },
          style = "nvim_aider",
          position = "right",
        },
      })
    end,
    -- stylua: ignore
    keys = {
      { "<leader>ai", "<C-\\><C-n><cmd>AiderTerminalToggle<cr>", desc = "Open Aider", mode = { "t" } },
      { "<leader>ai", "<cmd>AiderTerminalToggle<cr>", desc = "Open Aider" },
      { "<leader>as", "<cmd>AiderTerminalSend<cr>", desc = "Send to Aider", mode = { "n", "v" } },
      { "<leader>ac", "<cmd>AiderQuickSendCommand<cr>", desc = "Send Command To Aider" },
      { "<leader>ab", "<cmd>AiderQuickSendBuffer<cr>", desc = "Send Buffer To Aider" },
      { "<leader>a=", function() cmd_notif("AiderQuickAddFile") end, desc = "Add File to Aider" },
      { "<leader>a-", function() cmd_notif("AiderQuickDropFile") end, desc = "Drop File from Aider" },
      { "<leader>ar", function() cmd_notif("AiderQuickReadOnlyFile") end, desc = "Add File as Read-Only" },
    },
  },
}
