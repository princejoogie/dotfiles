return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"marilari88/neotest-vitest",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-vitest")({
						vitestCommand = "npx vitest",
					}),
				},
			})
		end,
		keys = {
			{ "<leader>,", function() end, desc = "[NeoTest] -->" },
			{
				"<leader>,s",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "[Test] Toggle summary",
			},
			{
				"<leader>,e",
				function()
					require("neotest").output.open()
				end,
				desc = "[Test] Output open",
			},
			{
				"<leader>,r",
				function()
					require("neotest").run.run()
				end,
				desc = "[Test] Run nearest",
			},
			{
				"<leader>,w",
				function()
					require("neotest").watch.toggle(vim.fn.expand("%"))
				end,
				desc = "[Test] Watch file",
			},
			{
				"<leader>,f",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "[Test] Run file",
			},
		},
	},
}
