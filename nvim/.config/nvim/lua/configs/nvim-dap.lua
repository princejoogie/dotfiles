local dapui = safe_require("dapui")
local dap = safe_require("dap")
local vtext = safe_require("nvim-dap-virtual-text")

if not (dapui and dap and vtext) then
	return
end

local M = {}

M.setup = function()
	vtext.setup({
		enabled = true,
		enabled_commands = true,
		highlight_changed_variables = true,
		highlight_new_as_changed = true,
		show_stop_reason = true,
		commented = false,
		virt_text_pos = "eol",
	})

	dapui.setup()

	dap.listeners.after.event_initialized["dapui_config"] = function()
		dapui.open()
	end

	dap.listeners.before.event_terminated["dapui_config"] = function()
		dapui.close()
	end

	dap.listeners.before.event_exited["dapui_config"] = function()
		dapui.close()
	end

	-- Node
	dap.adapters.node2 = {
		type = "executable",
		command = "node",
		args = { os.getenv("HOME") .. "/.local/share/nvim/vscode-node-debug2/out/src/nodeDebug.js" },
	}

	dap.configurations.javascript = {
		{
			name = "Launch",
			type = "node2",
			request = "launch",
			program = "${file}",
			cwd = vim.fn.getcwd(),
			sourceMaps = true,
			protocol = "inspector",
			console = "integratedTerminal",
		},
		{
			name = "Attach to process",
			type = "node2",
			request = "attach",
			processId = require("dap.utils").pick_process,
		},
	}

	-- C/C++/Rust
	dap.adapters.lldb = {
		type = "executable",
		command = "/usr/bin/lldb-vscode-10", -- adjust as needed
		name = "lldb",
	}

	dap.configurations.cpp = {
		{
			name = "Launch",
			type = "lldb",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			args = {},
			runInTerminal = false,
		},
	}

	dap.configurations.c = dap.configurations.cpp
	dap.configurations.rust = dap.configurations.cpp
end

return M
