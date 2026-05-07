local M = {}

local function opencode_server_url()
  local url = vim.g.opencode_server_url or vim.env.OPENCODE_SERVER_URL or "http://localhost:4096"
  return url:gsub("/+$", "")
end

local function opencode_directory()
  local directory = vim.g.opencode_directory or vim.env.OPENCODE_DIRECTORY
  if directory and directory ~= "" then
    return directory
  end
end

local function opencode_curl_args(path)
  local args = {
    "curl",
    "--silent",
    "--show-error",
    "--fail-with-body",
    "--max-time",
    "2",
    "--request",
    "POST",
    "--header",
    "Content-Type: application/json",
    "--data-binary",
    "@-",
  }

  local directory = opencode_directory()
  if directory then
    vim.list_extend(args, { "--header", "x-opencode-directory: " .. directory })
  end

  if vim.env.OPENCODE_SERVER_PASSWORD and vim.env.OPENCODE_SERVER_PASSWORD ~= "" then
    vim.list_extend(args, {
      "--user",
      (vim.env.OPENCODE_SERVER_USERNAME or "opencode") .. ":" .. vim.env.OPENCODE_SERVER_PASSWORD,
    })
  end

  table.insert(args, opencode_server_url() .. path)
  return args
end

local function notify(message, level)
  vim.notify(message, level, { title = "opencode" })
end

local function post_to_opencode(path, body, on_exit)
  if vim.fn.executable("curl") ~= 1 then
    notify("curl is required to talk to the opencode server", vim.log.levels.ERROR)
    return
  end

  local json = vim.json.encode(body)
  local args = opencode_curl_args(path)

  if vim.system then
    vim.system(args, { text = true, stdin = json }, function(result)
      vim.schedule(function()
        on_exit(result.code, (result.stderr or "") .. (result.stdout or ""))
      end)
    end)
    return
  end

  local output = {}
  local job = vim.fn.jobstart(args, {
    stdin = "pipe",
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      vim.list_extend(output, data or {})
    end,
    on_stderr = function(_, data)
      vim.list_extend(output, data or {})
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        on_exit(code, table.concat(output, "\n"))
      end)
    end,
  })

  if job <= 0 then
    notify("Failed to start curl", vim.log.levels.ERROR)
    return
  end

  vim.fn.chansend(job, json)
  vim.fn.chanclose(job, "stdin")
end

M.send_highlighted_to_opencode = function()
  local vstart = vim.fn.getpos("'<")
  local vend = vim.fn.getpos("'>")

  local line_start = vstart[2]
  local line_end = vend[2]

  if line_start == 0 or line_end == 0 then
    notify("No text selected", vim.log.levels.WARN)
    return
  end

  if line_start > line_end then
    line_start, line_end = line_end, line_start
  end

  local lines = vim.fn.getline(line_start, line_end)
  local selected_text = table.concat(lines, "\n")

  if selected_text == "" then
    notify("No text selected", vim.log.levels.WARN)
    return
  end

  post_to_opencode("/tui/append-prompt", { text = selected_text }, function(code, output)
    if code == 0 then
      notify("Sent selection to opencode", vim.log.levels.INFO)
      return
    end

    local message = (output or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if message == "" then
      message = "Could not reach opencode at "
        .. opencode_server_url()
        .. ". Start opencode with an external server, for example: opencode --port 4096"
    end
    notify(message, vim.log.levels.ERROR)
  end)
end

vim.api.nvim_create_user_command("OpencodeSend", M.send_highlighted_to_opencode, {
  nargs = 0,
  range = true,
  desc = "Send highlighted text to opencode",
})

vim.keymap.set("v", "<leader>os", ":<C-u>OpencodeSend<cr>", { desc = "Send highlighted text to opencode" })

return M
