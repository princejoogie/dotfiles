local RunningIcon = ""

local function find_project_root(start_path)
  local current_dir = vim.fn.fnamemodify(start_path, ":h")
  while true do
    if vim.fn.filereadable(current_dir .. "/package.json") == 1 then
      return current_dir
    end
    local parent_dir = vim.fn.fnamemodify(current_dir, ":h")
    if parent_dir == current_dir then
      return nil
    end
    current_dir = parent_dir
  end
end

local function simple_exec(commands, msg, cwd)
  local id = table.concat(commands, " ")
  local _msg = msg or id
  local success_msg = ""
  local error_msg = ""

  vim.notify(RunningIcon .. " " .. _msg, vim.log.levels.INFO, {
    title = "NodeExec Running",
    id = id,
  })

  local command_str = commands[1]
  local cmd_parts = vim.fn.has("win32") == 1 and { "cmd.exe", "/c", command_str } or { "/bin/sh", "-c", command_str }

  local job_opts = {
    stdout_buffered = true,
    stderr_buffered = true,
    cwd = cwd,
    on_stdout = function(_, data)
      if data and #data > 0 and data[1] ~= "" then
        local output = table.concat(data, "\n")
        output = output:gsub("^%s+", ""):gsub("%s+$", "")
        success_msg = output
      end
    end,
    on_stderr = function(_, err)
      if err and #err > 0 and err[1] ~= "" then
        local error_output = table.concat(err, "\n")
        error_output = error_output:gsub("^%s+", ""):gsub("%s+$", "")
        error_msg = error_output
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code ~= 0 then
          vim.notify(error_msg, vim.log.levels.ERROR, {
            id = id,
            title = "NodeExec Error",
          })
        else
          vim.notify(success_msg, vim.log.levels.INFO, {
            id = id,
            title = "NodeExec Success",
          })
        end
      end)
    end,
  }

  vim.fn.jobstart(cmd_parts, job_opts)
end

local function run_node_code()
  local file_to_run = vim.api.nvim_buf_get_name(0)
  if file_to_run == "" then
    vim.notify("Cannot execute unsaved buffer.", vim.log.levels.WARN, { title = "NodeExec" })
    return
  end
  file_to_run = vim.fn.expand(file_to_run)

  local project_root = find_project_root(file_to_run)
  local execution_cwd = project_root or vim.fn.fnamemodify(file_to_run, ":h")

  local quoted_file_to_run = '"' .. file_to_run .. '"'
  local command = "npx tsx " .. quoted_file_to_run
  local msg = " Executing " .. vim.fn.fnamemodify(file_to_run, ":t")

  simple_exec({ command }, msg, execution_cwd)
end

vim.api.nvim_create_user_command("NodeExec", run_node_code, {
  nargs = 0,
  desc = "Execute current file with npx tsx",
})

vim.keymap.set("n", "<leader>ne", "<cmd>NodeExec<cr>", { desc = "Execute current file with npx tsx" })
