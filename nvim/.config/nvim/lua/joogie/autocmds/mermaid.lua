local M = {}

local config = {
  keymaps = {
    toggle = "<C-m>",
  },
  popup = {
    min_width = 40,
    min_height = 8,
    padding = 4,
  },
  render_timeout_ms = 5000,
}

local preview_state = {
  buf = nil,
  win = nil,
}

local warned_missing_merman = false
local markdown_mermaid_query = nil

local markdown_mermaid_query_text = [[
(fenced_code_block
  (info_string
    (language) @language)
  (code_fence_content) @content) @block
]]

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Mermaid" })
end

local function bounded(value, min, max)
  if max < min then
    return max
  end

  return math.min(math.max(value, min), max)
end

local function valid_window(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function valid_buffer(buf)
  return buf and vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf)
end

local function close_preview()
  if valid_window(preview_state.win) then
    pcall(vim.api.nvim_win_close, preview_state.win, true)
  end

  if valid_buffer(preview_state.buf) then
    pcall(vim.api.nvim_buf_delete, preview_state.buf, { force = true })
  end

  preview_state.buf = nil
  preview_state.win = nil
end

local function fence_language(line)
  return line:match("^%s*```%s*([^%s`]*)%s*$")
end

local function is_fence(line)
  return line:match("^%s*```") ~= nil
end

local function is_mermaid_language(language)
  language = (language or ""):lower()
  return language == "mermaid" or language == "{mermaid}"
end

local function trim(text)
  return text:gsub("^%s+", ""):gsub("%s+$", "")
end

local function cursor_in_node(node)
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local start_row, _, end_row = node:range()

  return cursor_line >= start_row and cursor_line < end_row
end

local function get_markdown_mermaid_query()
  if markdown_mermaid_query then
    return markdown_mermaid_query
  end

  local ok, query = pcall(vim.treesitter.query.parse, "markdown", markdown_mermaid_query_text)
  if not ok then
    return nil
  end

  markdown_mermaid_query = query
  return query
end

local function first_capture_node(match, capture_id)
  local node = match[capture_id]
  if type(node) == "table" then
    return node[1]
  end

  return node
end

local function mermaid_block_at_cursor_from_treesitter(buf)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
  if not ok or not parser then
    return nil
  end

  local query = get_markdown_mermaid_query()
  if not query then
    return nil
  end

  local tree = parser:parse()[1]
  if not tree then
    return nil
  end

  local root = tree:root()
  for _, match in query:iter_matches(root, buf, 0, -1) do
    local captures = {}
    for id, name in ipairs(query.captures) do
      captures[name] = first_capture_node(match, id)
    end

    local language = captures.language
    local content = captures.content
    local block = captures.block

    if language and content and block and cursor_in_node(block) then
      local language_text = trim(vim.treesitter.get_node_text(language, buf))
      if is_mermaid_language(language_text) then
        local content_text = vim.treesitter.get_node_text(content, buf)
        return vim.split(content_text, "\n", { plain = true })
      end
    end
  end

  return nil
end

local function mermaid_block_at_cursor_from_lines(buf)
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local open_line = nil
  local open_language = nil

  for line_number, line in ipairs(lines) do
    if is_fence(line) then
      if open_line then
        if cursor_line >= open_line and cursor_line <= line_number and is_mermaid_language(open_language) then
          return vim.list_slice(lines, open_line + 1, line_number - 1)
        end

        open_line = nil
        open_language = nil
      else
        open_line = line_number
        open_language = fence_language(line)
      end
    end

    if line_number > cursor_line and not open_line then
      break
    end
  end

  return nil
end

local function mermaid_block_at_cursor(buf)
  return mermaid_block_at_cursor_from_treesitter(buf) or mermaid_block_at_cursor_from_lines(buf)
end

local function render_mermaid(lines)
  if vim.fn.executable("merman") ~= 1 then
    if not warned_missing_merman then
      notify("merman executable not found", vim.log.levels.WARN)
      warned_missing_merman = true
    end
    return nil
  end

  local path = vim.fn.tempname() .. ".mmd"
  if vim.fn.writefile(lines, path) ~= 0 then
    notify("Could not write temporary mermaid file", vim.log.levels.ERROR)
    return nil
  end

  local output = {}
  local error_output = {}
  local job = vim.fn.jobstart({ "merman", "--no-color", "--file", path }, {
    pty = true,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      vim.list_extend(output, data or {})
    end,
    on_stderr = function(_, data)
      vim.list_extend(error_output, data or {})
    end,
  })

  if job <= 0 then
    vim.fn.delete(path)
    notify("Could not start merman", vim.log.levels.ERROR)
    return nil
  end

  local result = vim.fn.jobwait({ job }, config.render_timeout_ms)[1]
  vim.fn.delete(path)

  if result == -1 then
    pcall(vim.fn.jobstop, job)
    notify("merman render timed out", vim.log.levels.WARN)
    return nil
  end

  if result ~= 0 or #output == 0 then
    local message = table.concat(error_output, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
    notify(message ~= "" and message or "merman could not render this diagram", vim.log.levels.WARN)
    return nil
  end

  for index, line in ipairs(output) do
    output[index] = line:gsub("\r", "")
  end

  while #output > 0 and output[#output] == "" do
    table.remove(output)
  end

  if #output == 0 then
    notify("merman could not render this diagram", vim.log.levels.WARN)
    return nil
  end

  return output
end

local function line_width(lines)
  local width = 1
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  return width
end

local function open_float(buf, title, lines)
  local max_width = math.max(vim.o.columns - config.popup.padding, 1)
  local max_height = math.max(vim.o.lines - config.popup.padding, 1)
  local width = bounded(line_width(lines), config.popup.min_width, max_width)
  local height = bounded(#lines, config.popup.min_height, max_height)
  local row = math.max(math.floor((vim.o.lines - height) / 2) - 1, 0)
  local col = math.max(math.floor((vim.o.columns - width) / 2), 0)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
  })

  vim.wo[win].wrap = false
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].cursorline = false
  vim.wo[win].sidescrolloff = 0

  return win
end

local function open_preview(lines)
  local uv = vim.uv or vim.loop
  local buf = vim.api.nvim_create_buf(false, true)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "text"
  vim.api.nvim_buf_set_name(buf, "mermaid://preview/" .. uv.hrtime())
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modified = false
  vim.bo[buf].modifiable = false

  preview_state.buf = buf
  preview_state.win = open_float(buf, "Mermaid", lines)

  vim.keymap.set("n", config.keymaps.toggle, close_preview, { buffer = buf, desc = "Close mermaid preview" })
  vim.keymap.set("n", "q", close_preview, { buffer = buf, desc = "Close mermaid preview" })
  vim.keymap.set("n", "<Esc>", close_preview, { buffer = buf, desc = "Close mermaid preview" })
end

function M.toggle()
  if valid_window(preview_state.win) then
    close_preview()
    return
  end

  local lines = mermaid_block_at_cursor(vim.api.nvim_get_current_buf())
  if not lines then
    notify("Cursor is not inside a mermaid code block", vim.log.levels.WARN)
    return
  end

  local rendered = render_mermaid(lines)
  if rendered then
    open_preview(rendered)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("joogie_markdown_mermaid", { clear = true }),
  pattern = "markdown",
  callback = function(event)
    vim.keymap.set("n", config.keymaps.toggle, M.toggle, { buffer = event.buf, desc = "Toggle mermaid preview" })
  end,
  desc = "Set markdown mermaid preview keymap",
})

return M
