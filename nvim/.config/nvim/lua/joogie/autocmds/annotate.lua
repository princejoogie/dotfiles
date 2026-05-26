local M = {}

local config = {
  annotate_icon = "󰍨 ",
  show_ghost_annotations = true,
  ghost_max_length = 80,
  sign_highlight = "DiagnosticSignInfo",
  sign_priority = 8,
  keymaps = {
    add = "<leader>ana",
    list = "<leader>anl",
    delete = "<leader>and",
    delete_all = "<leader>anD",
  },
  list_keymaps = {
    open = "o",
    copy = "cc",
    copy_all = "ca",
    delete = "dd",
  },
  post_instruction = "after resolving each annotation, edit the item from .tmp/annotations.json and prepend the annotation with 'RESOLVED: '",
}

local subcommands = { "add", "list", "delete", "deleteall" }
local namespace = vim.api.nvim_create_namespace("joogie_annotate")
local ghost_namespace = vim.api.nvim_create_namespace("joogie_annotate_ghost")
local sign_name = "JoogieAnnotateSign"
local sign_group = "joogie_annotate_signs"

vim.fn.sign_define(sign_name, { text = config.annotate_icon, texthl = config.sign_highlight, numhl = "" })

---@alias AnnotateLineNumber integer|string

---@class AnnotateEntry
---@field filename string
---@field linenumber AnnotateLineNumber
---@field annotation string

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Annotate" })
end

local function current_buffer_path(buf)
  local path = vim.api.nvim_buf_get_name(buf or 0)
  if path == "" or path:match("^annotate://") then
    return nil
  end

  return vim.fn.fnamemodify(path, ":p")
end

local function repo_root(path)
  local start = path and path ~= "" and vim.fn.fnamemodify(path, ":p") or vim.fn.getcwd()
  if vim.fn.isdirectory(start) ~= 1 then
    start = vim.fn.fnamemodify(start, ":h")
  end

  if vim.fs and vim.fs.find then
    local git_dir = vim.fs.find(".git", { path = start, upward = true })[1]
    if git_dir then
      return vim.fn.fnamemodify(git_dir, ":h")
    end
  end

  if vim.fn.executable("git") == 1 then
    local result = vim.fn.systemlist({ "git", "-C", start, "rev-parse", "--show-toplevel" })
    if vim.v.shell_error == 0 and result[1] and result[1] ~= "" then
      return result[1]
    end
  end

  return vim.fn.getcwd()
end

local function relative_path(path, root)
  local absolute = vim.fn.fnamemodify(path, ":p")
  local normalized_root = vim.fn.fnamemodify(root, ":p"):gsub("/$", "")

  if absolute:sub(1, #normalized_root + 1) == normalized_root .. "/" then
    return absolute:sub(#normalized_root + 2)
  end

  return absolute
end

local function annotations_path(root)
  return root .. "/.tmp/annotations.json"
end

---@return AnnotateEntry[]?
local function read_annotations(root)
  local path = annotations_path(root)
  if vim.fn.filereadable(path) == 0 then
    return {}
  end

  local content = table.concat(vim.fn.readfile(path), "\n")
  if content:gsub("%s+", "") == "" then
    return {}
  end

  local ok, annotations = pcall(vim.json.decode, content)
  if not ok or type(annotations) ~= "table" then
    notify("Could not parse " .. path, vim.log.levels.ERROR)
    return nil
  end

  return annotations
end

---@param annotations AnnotateEntry[]
local function write_annotations(root, annotations)
  local directory = root .. "/.tmp"
  local path = annotations_path(root)
  vim.fn.mkdir(directory, "p")

  local ok, encoded = pcall(vim.json.encode, annotations)
  if not ok then
    notify("Could not encode annotations: " .. tostring(encoded), vim.log.levels.ERROR)
    return false
  end

  local success, result = pcall(vim.fn.writefile, { encoded }, path)
  if not success or result ~= 0 then
    notify("Could not write " .. path, vim.log.levels.ERROR)
    return false
  end

  return true
end

local function line_label(annotation)
  return tostring(annotation.linenumber or "")
end

local function annotation_text(annotation)
  return tostring(annotation.annotation or "")
end

local function ghost_annotation_text(annotation)
  local text = annotation_text(annotation):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  if text == "" then
    return nil
  end

  if vim.fn.strchars(text) > config.ghost_max_length then
    text = vim.fn.strcharpart(text, 0, config.ghost_max_length - 3) .. "..."
  end

  return text
end

local function formatted_annotation(annotation)
  return ("file: %s:%s\nannotation: %s"):format(annotation.filename or "", line_label(annotation), annotation_text(annotation))
end

local function append_post_instruction(text)
  if not config.post_instruction or config.post_instruction == "" then
    return text
  end

  return text .. "\n\n" .. config.post_instruction
end

local function copy_to_clipboard(text, success_message)
  vim.fn.setreg('"', text)

  local ok = pcall(vim.fn.setreg, "+", text)
  if ok then
    notify(success_message)
  else
    notify(success_message .. " to unnamed register", vim.log.levels.WARN)
  end
end

local function bounded(value, min, max)
  if max < min then
    return max
  end

  return math.min(math.max(value, min), max)
end

---@param linenumber AnnotateLineNumber
---@return integer?, integer?
local function line_range(linenumber)
  if type(linenumber) == "number" then
    return linenumber, linenumber
  end

  local line_string = tostring(linenumber)
  local start_line, end_line = line_string:match("^(%d+)%-(%d+)$")
  if start_line and end_line then
    local start_number = tonumber(start_line)
    local end_number = tonumber(end_line)
    if not start_number or not end_number then
      return nil, nil
    end

    if start_number > end_number then
      start_number, end_number = end_number, start_number
    end

    return start_number, end_number
  end

  local line_number = tonumber(line_string)
  if line_number then
    return line_number, line_number
  end

  return nil, nil
end

local function annotation_at_line(annotations, filename, line)
  for index, annotation in ipairs(annotations) do
    local start_line, end_line = line_range(annotation.linenumber)
    if annotation.filename == filename and start_line and end_line and line >= start_line and line <= end_line then
      return annotation, index
    end
  end

  return nil, nil
end

local function refresh_annotation_signs(buf, annotations, root)
  buf = buf or vim.api.nvim_get_current_buf()
  vim.fn.sign_unplace(sign_group, { buffer = buf })

  local path = current_buffer_path(buf)
  if not path then
    return
  end

  root = root or repo_root(path)
  annotations = annotations or read_annotations(root)
  if not annotations then
    return
  end

  local filename = relative_path(path, root)
  local line_count = vim.api.nvim_buf_line_count(buf)
  local signed_lines = {}

  vim.b[buf].annotate_source_annotations = annotations
  vim.b[buf].annotate_source_filename = filename
  vim.b[buf].annotate_source_root = root

  for _, annotation in ipairs(annotations) do
    if annotation.filename == filename then
      local start_line, end_line = line_range(annotation.linenumber)
      if start_line and end_line and end_line >= 1 and start_line <= line_count then
        local sign_line = bounded(end_line, 1, line_count)
        if not signed_lines[sign_line] then
          signed_lines[sign_line] = true
          vim.fn.sign_place(sign_line, sign_group, sign_name, buf, { lnum = sign_line, priority = config.sign_priority })
        end
      end
    end
  end
end

local function refresh_annotation_signs_for_root(root)
  local annotations = read_annotations(root)
  if not annotations then
    return
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local path = current_buffer_path(buf)
      if path and repo_root(path) == root then
        refresh_annotation_signs(buf, annotations, root)
      end
    end
  end
end

local function open_float(buf, title, opts)
  opts = opts or {}

  local max_width = math.max(vim.o.columns - 4, 1)
  local max_height = math.max(vim.o.lines - 4, 1)
  local width = bounded(opts.width or math.floor(vim.o.columns * 0.7), opts.min_width or 50, max_width)
  local height = bounded(opts.height or math.floor(vim.o.lines * 0.5), opts.min_height or 10, max_height)
  local relative = opts.relative or "editor"
  local anchor = opts.anchor
  local row = math.max(math.floor((vim.o.lines - height) / 2) - 1, 0)
  local col = math.max(math.floor((vim.o.columns - width) / 2), 0)

  if relative == "cursor" then
    local window_width = vim.fn.winwidth(0)
    local cursor_column = vim.fn.wincol()
    local columns_right = window_width - cursor_column
    local lines_below = vim.fn.winheight(0) - vim.fn.winline()

    row = 1
    col = 0

    if lines_below < height + 2 then
      anchor = "SW"
      row = 0
    end

    if columns_right < width + 2 then
      col = math.max(-(cursor_column - 1), columns_right - width - 2)
    end
  end

  local window_opts = {
    relative = relative,
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
  }

  if anchor then
    window_opts.anchor = anchor
  end

  local win = vim.api.nvim_open_win(buf, true, window_opts)

  vim.wo[win].cursorline = true
  vim.wo[win].wrap = true

  return win
end

local function source_context(opts)
  local path = current_buffer_path()
  if not path then
    notify("Cannot annotate this buffer", vim.log.levels.WARN)
    return nil
  end

  local root = repo_root(path)
  local line1 = vim.api.nvim_win_get_cursor(0)[1]
  local line2 = line1

  if opts and opts.range and opts.range > 0 then
    line1 = opts.line1
    line2 = opts.line2
  end

  if line1 > line2 then
    line1, line2 = line2, line1
  end

  local linenumber = line1 == line2 and line1 or (line1 .. "-" .. line2)

  return {
    root = root,
    filename = relative_path(path, root),
    linenumber = linenumber,
  }
end

local function buffer_annotation(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  while #lines > 0 and lines[1]:match("^%s*$") do
    table.remove(lines, 1)
  end

  while #lines > 0 and lines[#lines]:match("^%s*$") do
    table.remove(lines)
  end

  return table.concat(lines, "\n")
end

local function save_annotation(buf, context)
  local annotation = buffer_annotation(buf)
  local annotations = read_annotations(context.root)
  if not annotations then
    return
  end

  if annotation == "" then
    if context.saved_index and annotations[context.saved_index] then
      table.remove(annotations, context.saved_index)
      if write_annotations(context.root, annotations) then
        vim.bo[buf].modified = false
        refresh_annotation_signs_for_root(context.root)
        notify("Annotation deleted")
      end
      return
    end

    notify("Annotation is empty", vim.log.levels.WARN)
    vim.bo[buf].modified = false
    return
  end

  local entry = {
    filename = context.filename,
    linenumber = context.linenumber,
    annotation = annotation,
  }

  if context.saved_index and annotations[context.saved_index] then
    annotations[context.saved_index] = entry
  else
    table.insert(annotations, entry)
    context.saved_index = #annotations
  end

  if write_annotations(context.root, annotations) then
    vim.bo[buf].modified = false
    refresh_annotation_signs_for_root(context.root)
    notify("Annotation saved")
  end
end

local function split_annotation_lines(text)
  if text == "" then
    return { "" }
  end

  return vim.split(text, "\n", { plain = true })
end

local function render_list(buf, root, annotations)
  local lines = {
    ("Shortcuts: %s open source | %s copy annotation | %s copy all annotations | %s delete annotation"):format(
      config.list_keymaps.open,
      config.list_keymaps.copy,
      config.list_keymaps.copy_all,
      config.list_keymaps.delete
    ),
    "",
  }
  local line_map = {}

  if #annotations == 0 then
    table.insert(lines, "No annotations.")
  else
    for index, annotation in ipairs(annotations) do
      local start_line = #lines + 1
      local annotation_lines = split_annotation_lines(annotation_text(annotation))

      table.insert(lines, ("file: %s:%s"):format(annotation.filename or "", line_label(annotation)))
      table.insert(lines, "annotation: " .. annotation_lines[1])

      for i = 2, #annotation_lines do
        table.insert(lines, annotation_lines[i])
      end

      table.insert(lines, "")
      table.insert(lines, "---")
      table.insert(lines, "")

      for line = start_line, #lines do
        line_map[line] = index
      end
    end
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, namespace, "Comment", 0, 0, -1)
  vim.bo[buf].modified = false
  vim.bo[buf].modifiable = false
  vim.b[buf].annotate_root = root
  vim.b[buf].annotate_line_map = line_map
end

local function current_annotations_root()
  if vim.b.annotate_root then
    return vim.b.annotate_root
  end

  return repo_root(current_buffer_path())
end

local function list_annotation_at_cursor(buf)
  local line_map = vim.b[buf].annotate_line_map or {}
  local index = line_map[vim.api.nvim_win_get_cursor(0)[1]]
  if not index then
    return nil, nil
  end

  local root = vim.b[buf].annotate_root
  local annotations = read_annotations(root)
  if not annotations then
    return nil, nil
  end

  return annotations[index], index, annotations, root
end

local function copy_current_annotation(buf)
  local annotation = list_annotation_at_cursor(buf)
  if not annotation then
    notify("No annotation at current line", vim.log.levels.WARN)
    return
  end

  copy_to_clipboard(append_post_instruction(formatted_annotation(annotation)), "Copied annotation")
end

local function copy_all_annotations(buf)
  local root = vim.b[buf].annotate_root
  local annotations = read_annotations(root)
  if not annotations then
    return
  end

  if #annotations == 0 then
    notify("No annotations to copy", vim.log.levels.WARN)
    return
  end

  local formatted = {}
  for _, annotation in ipairs(annotations) do
    table.insert(formatted, formatted_annotation(annotation))
  end

  copy_to_clipboard(append_post_instruction(table.concat(formatted, "\n\n---\n\n")), "Copied all annotations")
end

local function annotation_path(root, annotation)
  local filename = annotation.filename or ""
  if filename == "" then
    return nil
  end

  if filename:match("^/") then
    return vim.fn.fnamemodify(filename, ":p")
  end

  return vim.fn.fnamemodify(root .. "/" .. filename, ":p")
end

local function normal_window(win)
  return win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ""
end

local function find_normal_window_for_buffer(buf)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if normal_window(win) and vim.api.nvim_win_get_buf(win) == buf then
      return win
    end
  end

  return nil
end

local function find_loaded_buffer(path)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p") == path then
      return buf
    end
  end

  return nil
end

local function fallback_window(preferred_win)
  if normal_window(preferred_win) then
    return preferred_win
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if normal_window(win) then
      return win
    end
  end

  return nil
end

local function jump_to_annotation_line(annotation)
  local start_line = line_range(annotation.linenumber)
  if not start_line then
    return
  end

  local line_count = vim.api.nvim_buf_line_count(0)
  pcall(vim.api.nvim_win_set_cursor, 0, { bounded(start_line, 1, line_count), 0 })
end

local function open_source_annotation(buf, list_win, source_win)
  local annotation, _, _, root = list_annotation_at_cursor(buf)
  if not annotation then
    notify("No annotation at current line", vim.log.levels.WARN)
    return
  end

  local path = annotation_path(root, annotation)
  if not path then
    notify("Annotation has no file", vim.log.levels.WARN)
    return
  end

  local target_buf = find_loaded_buffer(path)
  local target_win = target_buf and find_normal_window_for_buffer(target_buf) or fallback_window(source_win)

  if list_win and vim.api.nvim_win_is_valid(list_win) then
    pcall(vim.api.nvim_win_close, list_win, true)
  end

  if target_win and vim.api.nvim_win_is_valid(target_win) then
    vim.api.nvim_set_current_win(target_win)
  end

  if target_buf then
    vim.api.nvim_win_set_buf(0, target_buf)
  else
    vim.cmd.edit(vim.fn.fnameescape(path))
  end

  jump_to_annotation_line(annotation)
end

local function delete_list_annotation(buf)
  local _, index, annotations, root = list_annotation_at_cursor(buf)
  if not index then
    notify("No annotation at current line", vim.log.levels.WARN)
    return
  end

  table.remove(annotations, index)
  if write_annotations(root, annotations) then
    refresh_annotation_signs_for_root(root)
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    render_list(buf, root, annotations)
    local line_count = vim.api.nvim_buf_line_count(buf)
    pcall(vim.api.nvim_win_set_cursor, 0, { math.min(current_line, line_count), 0 })
    notify("Annotation deleted")
  end
end

---@param linenumber AnnotateLineNumber
---@param line integer
local function line_contains(linenumber, line)
  local start_line, end_line = line_range(linenumber)
  return start_line ~= nil and end_line ~= nil and line >= start_line and line <= end_line
end

local function source_annotation_at_cursor()
  local path = current_buffer_path()
  if not path then
    return nil, nil, nil, nil
  end

  local root = repo_root(path)
  local filename = relative_path(path, root)
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local annotations = read_annotations(root)
  if not annotations then
    return nil, nil, nil, root
  end

  local annotation, index = annotation_at_line(annotations, filename, current_line)
  if annotation then
    return annotation, index, annotations, root
  end

  return nil, nil, annotations, root
end

local function cached_source_annotation_at_cursor(buf)
  buf = buf or vim.api.nvim_get_current_buf()

  local annotations = vim.b[buf].annotate_source_annotations
  local filename = vim.b[buf].annotate_source_filename
  if not annotations or not filename then
    refresh_annotation_signs(buf)
    annotations = vim.b[buf].annotate_source_annotations
    filename = vim.b[buf].annotate_source_filename
  end

  if not annotations or not filename then
    return nil
  end

  return annotation_at_line(annotations, filename, vim.api.nvim_win_get_cursor(0)[1])
end

local function clear_annotation_ghost(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(buf, ghost_namespace, 0, -1)
end

local function refresh_annotation_ghost()
  local buf = vim.api.nvim_get_current_buf()
  clear_annotation_ghost(buf)

  if not config.show_ghost_annotations then
    return
  end

  local annotation = cached_source_annotation_at_cursor(buf)
  if not annotation then
    return
  end

  local text = ghost_annotation_text(annotation)
  if not text then
    return
  end

  local line = vim.api.nvim_win_get_cursor(0)[1] - 1
  vim.api.nvim_buf_set_extmark(buf, ghost_namespace, line, 0, {
    virt_text = { { " " .. text, "Comment" } },
    virt_text_pos = "eol",
    hl_mode = "combine",
    priority = 80,
  })
end

local function delete_source_annotation()
  local annotation, index, annotations, root = source_annotation_at_cursor()
  if not root then
    notify("Cannot delete annotations from this buffer", vim.log.levels.WARN)
    return
  end

  if not annotations then
    return
  end

  if annotation and index then
    table.remove(annotations, index)
    if write_annotations(root, annotations) then
      refresh_annotation_signs_for_root(root)
      notify("Annotation deleted")
    end
    return
  end

  notify("No annotation at current line", vim.log.levels.WARN)
end

local function open_annotation_editor(annotation, index, root)
  local lines = split_annotation_lines(annotation_text(annotation))
  local buf = vim.api.nvim_create_buf(false, true)
  local uv = vim.uv or vim.loop

  vim.bo[buf].buftype = "acwrite"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_buf_set_name(buf, ("annotate://edit/%s:%s/%s"):format(annotation.filename or "", line_label(annotation), uv.hrtime()))
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modified = false

  local context = {
    root = root,
    filename = annotation.filename,
    linenumber = annotation.linenumber,
    saved_index = index,
  }

  local group = vim.api.nvim_create_augroup("joogie_annotate_edit_" .. buf, { clear = true })
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = group,
    buffer = buf,
    callback = function()
      save_annotation(buf, context)
    end,
  })

  open_float(buf, ("Annotation %s:%s"):format(annotation.filename or "", line_label(annotation)), {
    relative = "cursor",
    width = 48,
    height = bounded(#lines, 3, 12),
    min_width = 30,
    min_height = 3,
  })
  vim.cmd("startinsert")
end

function M.add(opts)
  if not (opts and opts.range and opts.range > 0) then
    local annotation, index, annotations, root = source_annotation_at_cursor()
    if not annotations and root then
      return
    end

    if annotation and index and root then
      open_annotation_editor(annotation, index, root)
      return
    end
  end

  local context = source_context(opts)
  if not context then
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local uv = vim.uv or vim.loop

  vim.bo[buf].buftype = "acwrite"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_buf_set_name(buf, ("annotate://%s:%s/%s"):format(context.filename, context.linenumber, uv.hrtime()))

  local group = vim.api.nvim_create_augroup("joogie_annotate_add_" .. buf, { clear = true })
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = group,
    buffer = buf,
    callback = function()
      save_annotation(buf, context)
    end,
  })

  open_float(buf, ("Annotate %s:%s"):format(context.filename, context.linenumber), {
    relative = "cursor",
    width = 48,
    height = 3,
    min_width = 30,
    min_height = 3,
  })
  vim.cmd("startinsert")
end

function M.list()
  local root = current_annotations_root()
  local annotations = read_annotations(root)
  if not annotations then
    return
  end

  local source_win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  local uv = vim.uv or vim.loop

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_buf_set_name(buf, "annotate://list/" .. uv.hrtime())

  render_list(buf, root, annotations)
  local list_win = open_float(buf, "Annotations")

  vim.keymap.set("n", config.list_keymaps.open, function()
    open_source_annotation(buf, list_win, source_win)
  end, { buffer = buf, desc = "Open annotation source" })

  vim.keymap.set("n", config.list_keymaps.copy, function()
    copy_current_annotation(buf)
  end, { buffer = buf, desc = "Copy annotation" })

  vim.keymap.set("n", config.list_keymaps.copy_all, function()
    copy_all_annotations(buf)
  end, { buffer = buf, desc = "Copy all annotations" })

  vim.keymap.set("n", config.list_keymaps.delete, function()
    delete_list_annotation(buf)
  end, { buffer = buf, desc = "Delete annotation" })
end

function M.delete()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].annotate_line_map then
    delete_list_annotation(buf)
    return
  end

  delete_source_annotation()
end

function M.deleteall()
  local root = current_annotations_root()
  if write_annotations(root, {}) then
    refresh_annotation_signs_for_root(root)
    local buf = vim.api.nvim_get_current_buf()
    if vim.b[buf].annotate_line_map then
      render_list(buf, root, {})
    end
    notify("Annotations cleared")
  end
end

vim.api.nvim_create_user_command("Annotate", function(opts)
  local command = opts.fargs[1]

  if command == "add" then
    M.add(opts)
  elseif command == "list" then
    M.list()
  elseif command == "delete" then
    M.delete()
  elseif command == "deleteall" then
    M.deleteall()
  else
    notify("Usage: :Annotate add|list|delete|deleteall", vim.log.levels.WARN)
  end
end, {
  nargs = "*",
  range = true,
  complete = function(arg_lead)
    return vim.tbl_filter(function(command)
      return command:find(arg_lead, 1, true) == 1
    end, subcommands)
  end,
  desc = "Manage file annotations",
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost", "BufWritePost", "FocusGained" }, {
  group = vim.api.nvim_create_augroup("joogie_annotate_refresh_signs", { clear = true }),
  callback = function(event)
    local buf = event.buf and event.buf ~= 0 and event.buf or vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_loaded(buf) then
      refresh_annotation_signs(buf)
    end
  end,
  desc = "Refresh annotation signs",
})

local ghost_group = vim.api.nvim_create_augroup("joogie_annotate_ghost_text", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved", "FocusGained" }, {
  group = ghost_group,
  callback = function()
    refresh_annotation_ghost()
  end,
  desc = "Show annotation ghost text",
})

vim.api.nvim_create_autocmd({ "BufLeave", "InsertEnter" }, {
  group = ghost_group,
  callback = function(event)
    clear_annotation_ghost(event.buf)
  end,
  desc = "Clear annotation ghost text",
})

vim.keymap.set("n", config.keymaps.add, "<cmd>Annotate add<cr>", { desc = "Add annotation" })
vim.keymap.set("v", config.keymaps.add, ":Annotate add<cr>", { desc = "Add annotation" })
vim.keymap.set("n", config.keymaps.list, "<cmd>Annotate list<cr>", { desc = "List annotations" })
vim.keymap.set("n", config.keymaps.delete, "<cmd>Annotate delete<cr>", { desc = "Delete annotation" })
vim.keymap.set("n", config.keymaps.delete_all, "<cmd>Annotate deleteall<cr>", { desc = "Delete all annotations" })

return M
