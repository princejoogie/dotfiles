return {
  dir = "~/documents/codes/duckdb.nvim",
  ft = { "csv" },
  opts = {
    rows_per_page = 50,
  },
  keys = {
    { "<leader>pn", "<cmd>DuckView next<cr>", desc = "Duck: Next page", ft = "duck_view" },
    { "<leader>pp", "<cmd>DuckView prev<cr>", desc = "Duck: Previous page", ft = "duck_view" },
    { "<leader>pf", "<cmd>DuckView first<cr>", desc = "Duck: First page", ft = "duck_view" },
    { "<leader>pl", "<cmd>DuckView last<cr>", desc = "Duck: Last page", ft = "duck_view" },
  },
}
