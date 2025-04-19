local cmd_notif = function(cmd)
  Snacks.notifier(cmd)
  vim.cmd(cmd)
end

return {
  {
    "GeorgesAlkhouri/nvim-aider",
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
      { "<leader>a", function() end, desc = "Aider" },
      { "<leader>ai", "<C-\\><C-n><cmd>Aider toggle<cr>", desc = "Open Aider", mode = { "t" } },
      { "<leader>ai", "<cmd>Aider toggle<cr>", desc = "Open Aider" },
      { "<leader>as", "<cmd>Aider send<cr>", desc = "Send to Aider", mode = { "n", "v" } },
      { "<leader>ac", "<cmd>Aider command<cr>", desc = "Send Command To Aider" },
      { "<leader>ab", "<cmd>Aider buffer<cr>", desc = "Send Buffer To Aider" },
      { "<leader>a=", function() cmd_notif("Aider add") end, desc = "Add File to Aider" },
      { "<leader>a-", function() cmd_notif("Aider drop") end, desc = "Drop File from Aider" },
      { "<leader>ar", function() cmd_notif("Aider add readonly") end, desc = "Add File as Read-Only" },
    },
  },
}
