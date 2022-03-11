local base = '<cmd>lua require("dap").'
local ui = '<cmd>lua require("dapui").'

local opts = {}

vim.api.nvim_set_keymap('n', '<leader>dp', base..'continue()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>do', base..'step_over()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>dn', base..'step_into()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>dN', base..'step_out()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>db', base..'toggle_breakpoint()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>dB', base..'set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>dr', base..'repl.toggle()<CR>', opts)

vim.api.nvim_set_keymap('n', '<leader>dt', ui..'toggle()<CR>', opts)

require('nvim-dap-virtual-text').setup {
	enabled = true,
	enabled_commands = true,
	highlight_changed_variables = true,
	highlight_new_as_changed = true,
	show_stop_reason = true,
	commented = false,
	virt_text_pos = 'eol',
}
require('dapui').setup()

local dap, dapui = require('dap'), require('dapui')

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
  type = 'executable',
	command = 'node',
	args = {os.getenv('HOME')..'/.local/share/nvim/vscode-node-debug2/out/src/nodeDebug.js'}
}

dap.configurations.javascript = {
  {
    name = 'Launch',
    type = 'node2',
    request = 'launch',
    program = '${file}',
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = 'inspector',
    console = 'integratedTerminal',
  },
  {
    -- For this to work you need to make sure the node process is started with the `--inspect` flag.
    name = 'Attach to process',
    type = 'node2',
    request = 'attach',
    processId = require'dap.utils'.pick_process,
  },
}

-- C/C++/Rust
dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-vscode-10', -- adjust as needed
  name = "lldb"
}
