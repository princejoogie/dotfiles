local M = {}

local config = {
  annotate_icon = "󰍨 ",
  resolved_annotate_icon = "󰄬 ",
  github_icon = " ",
  show_ghost_annotations = true,
  includeHunksOnCopy = true,
  ghost_max_length = 80,
  sign_highlight = "DiagnosticSignInfo",
  resolved_sign_highlight = "DiagnosticSignHint",
  resolved_highlight = "JoogieAnnotateResolved",
  sign_priority = 8,
  keymaps = {
    add = "<leader>ana",
    copy = "<leader>anc",
    list = "<leader>anl",
    delete = "<leader>and",
    delete_all = "<leader>anD",
    gh_comments = "<leader>ang",
    previous = "[a",
    next = "]a",
  },
  list_keymaps = {
    previous = "k",
    next = "j",
    open = "o",
    copy = "cc",
    copy_all = "ca",
    delete = "dd",
    toggle_resolved = "<space>",
  },
  post_instruction = "after resolving each annotation, use jq to edit the item from the annotations file and set its resolved property to true",
}

local subcommands = { "add", "copy", "list", "delete", "deleteall", "gh_comments" }
local namespace = vim.api.nvim_create_namespace("joogie_annotate")
local ghost_namespace = vim.api.nvim_create_namespace("joogie_annotate_ghost")
local sign_name = "JoogieAnnotateSign"
local resolved_sign_name = "JoogieAnnotateResolvedSign"
local sign_group = "joogie_annotate_signs"
local list_state = {
  buf = nil,
  win = nil,
  source_win = nil,
  cursor = nil,
}

vim.fn.sign_define(sign_name, { text = config.annotate_icon, texthl = config.sign_highlight, numhl = "" })
vim.fn.sign_define(
  resolved_sign_name,
  { text = config.resolved_annotate_icon, texthl = config.resolved_sign_highlight, numhl = "" }
)
vim.api.nvim_set_hl(0, config.resolved_highlight, { strikethrough = true })

---@alias AnnotateLineNumber integer|string

---@class AnnotateEntry
---@field filename string
---@field linenumber AnnotateLineNumber
---@field annotation string
---@field hunk? string
---@field resolved? boolean
---@field meta? table

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Annotate" })
end

local function checkout_root_from_git_worktree_dir(worktree_dir)
  local gitdir_path = worktree_dir .. "/gitdir"
  if vim.fn.filereadable(gitdir_path) == 0 then
    return nil
  end

  local gitdir = vim.fn.readfile(gitdir_path)[1]
  if not gitdir or gitdir == "" then
    return nil
  end

  gitdir = gitdir:gsub("%s+$", "")
  if not gitdir:match("^/") then
    gitdir = vim.fn.fnamemodify(worktree_dir .. "/" .. gitdir, ":p")
  end

  return vim.fn.fnamemodify(gitdir, ":h")
end

local function resolved_diffview_worktree_path(path)
  local worktree_dir, filename = path:match("^(.-/%.git/worktrees/[^/]+)/[^/]+/(.+)$")
  if not worktree_dir or not filename then
    return nil
  end

  local worktree_root = checkout_root_from_git_worktree_dir(worktree_dir)
  if not worktree_root then
    return nil
  end

  return vim.fn.fnamemodify(worktree_root .. "/" .. filename, ":p")
end

local function current_buffer_path(buf)
  local path = vim.api.nvim_buf_get_name(buf or 0)
  if path == "" or path:match("^annotate://") then
    return nil
  end

  local diffview_path = path:match("^diffview://(/.*)$")
  if diffview_path then
    local absolute = vim.fn.fnamemodify(diffview_path, ":p")
    local worktree_path = resolved_diffview_worktree_path(absolute)
    if worktree_path then
      return worktree_path, true, false
    end

    return absolute, true, true
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

local function annotation_filename(path, root, is_diffview, use_diffview_virtual_filename)
  local filename = relative_path(path, vim.fn.getcwd())
  if filename == vim.fn.fnamemodify(path, ":p") then
    filename = relative_path(path, root)
  end

  if is_diffview and use_diffview_virtual_filename ~= false then
    local worktree_filename = filename:match("^%.git/worktrees/[^/]+/[^/]+/(.+)$")
    if worktree_filename then
      return worktree_filename
    end

    local git_filename = filename:match("^%.git/[^/]+/(.+)$")
    if git_filename then
      return git_filename
    end

    filename = filename:gsub("^[^/]+/", "", 1)
  end

  return filename
end

local function source_is_diffview(buf)
  local _, is_diffview = current_buffer_path(buf)
  return is_diffview == true
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

  for _, annotation in ipairs(annotations) do
    if type(annotation) == "table" then
      annotation.resolved = annotation.resolved == true
    end
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

local function command_output(args, cwd)
  if vim.system then
    local result = vim.system(args, { cwd = cwd, text = true }):wait()
    return result.stdout or "", result.stderr or "", result.code or 0
  end

  local previous_cwd = cwd and vim.fn.getcwd() or nil
  if cwd then
    vim.fn.chdir(cwd)
  end

  local result = vim.fn.systemlist(args)
  local code = vim.v.shell_error

  if previous_cwd then
    vim.fn.chdir(previous_cwd)
  end

  return table.concat(result, "\n"), "", code
end

local function gh_error_message(stdout, stderr)
  local message = (stderr ~= "" and stderr or stdout):gsub("^%s+", ""):gsub("%s+$", "")
  return message ~= "" and message or "gh command failed"
end

local function gh_pr_number(root)
  local stdout, stderr, code = command_output({
    "gh",
    "pr",
    "view",
    "--json",
    "number",
    "--jq",
    ".number",
  }, root)
  if code ~= 0 then
    notify("Could not determine PR: " .. gh_error_message(stdout, stderr), vim.log.levels.ERROR)
    return nil
  end

  local pr = stdout:gsub("%s+", "")
  if pr == "" then
    notify("Could not determine PR for current branch", vim.log.levels.ERROR)
    return nil
  end

  return pr
end

local function flatten_gh_pages(data)
  local comments = {}

  if type(data) ~= "table" then
    return comments
  end

  for _, item in ipairs(data) do
    if type(item) == "table" and item.path then
      table.insert(comments, item)
    elseif type(item) == "table" then
      for _, comment in ipairs(item) do
        if type(comment) == "table" and comment.path then
          table.insert(comments, comment)
        end
      end
    end
  end

  return comments
end

local function gh_review_comments(root, pr)
  local stdout, stderr, code = command_output({
    "gh",
    "api",
    "--method",
    "GET",
    "--paginate",
    "--slurp",
    "-f",
    "per_page=100",
    "repos/{owner}/{repo}/pulls/" .. pr .. "/comments",
  }, root)

  if code ~= 0 then
    notify("Could not fetch PR comments: " .. gh_error_message(stdout, stderr), vim.log.levels.ERROR)
    return nil
  end

  local ok, data = pcall(vim.json.decode, stdout)
  if not ok then
    notify("Could not parse PR comments from gh", vim.log.levels.ERROR)
    return nil
  end

  return flatten_gh_pages(data)
end

local function json_value(value)
  if value == vim.NIL then
    return nil
  end

  return value
end

local function gh_comment_linenumber(comment)
  local start_line = tonumber(json_value(comment.start_line) or json_value(comment.original_start_line))
  local line = tonumber(json_value(comment.line) or json_value(comment.original_line))

  if start_line and line and start_line ~= line then
    if start_line > line then
      start_line, line = line, start_line
    end

    return ("%d-%d"):format(start_line, line)
  end

  return line or start_line
end

local function gh_comment_author(comment)
  if type(comment.user) == "table" then
    local login = json_value(comment.user.login)
    if login then
      return tostring(login)
    end
  end

  return "unknown"
end

local function gh_imported_annotations(annotations)
  local imported = {}

  for _, annotation in ipairs(annotations) do
    local meta = annotation.meta
    if type(meta) == "table" and meta.github == true and meta.comment_id then
      imported[tostring(meta.comment_id)] = annotation.resolved == true
    end
  end

  return imported
end

local function keep_non_gh_annotations(annotations)
  local kept = {}

  for _, annotation in ipairs(annotations) do
    local meta = annotation.meta
    if not (type(meta) == "table" and meta.github == true) then
      table.insert(kept, annotation)
    end
  end

  return kept
end

local function gh_comment_annotation(comment, previous_resolved, pr)
  local filename = json_value(comment.path)
  local linenumber = gh_comment_linenumber(comment)
  local body = tostring(json_value(comment.body) or "")

  if not filename or filename == "" or not linenumber or body == "" then
    return nil
  end

  local source_id = json_value(comment.id) or json_value(comment.node_id) or json_value(comment.html_url)
  if not source_id then
    source_id = filename .. ":" .. linenumber .. ":" .. body
  end

  source_id = tostring(source_id)
  local author = gh_comment_author(comment)

  return {
    filename = filename,
    linenumber = linenumber,
    annotation = body,
    hunk = tostring(json_value(comment.diff_hunk) or ""),
    resolved = previous_resolved[source_id] == true,
    meta = {
      github = true,
      pr_number = tonumber(pr) or pr,
      comment_id = source_id,
      author = author,
      url = json_value(comment.html_url),
    },
  }
end

local function line_label(annotation)
  return tostring(annotation.linenumber or "")
end

local function annotation_text(annotation)
  return tostring(annotation.annotation or "")
end

local function annotation_meta(annotation)
  return type(annotation.meta) == "table" and annotation.meta or {}
end

local function rendered_annotation_text(annotation)
  local text = annotation_text(annotation)
  local meta = annotation_meta(annotation)

  if meta.github == true then
    local author = meta.author and tostring(meta.author) or ""
    if author ~= "" then
      return config.github_icon .. "@" .. author .. ": " .. text
    end

    return config.github_icon .. text
  end

  return text
end

local function hunk_text(annotation)
  return tostring(annotation.hunk or "")
end

local function annotation_resolved(annotation)
  return annotation.resolved == true
end

local function ghost_annotation_text(annotation)
  local text = rendered_annotation_text(annotation):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  if text == "" then
    return nil
  end

  if vim.fn.strchars(text) > config.ghost_max_length then
    text = vim.fn.strcharpart(text, 0, config.ghost_max_length - 3) .. "..."
  end

  return text
end

local function formatted_annotation(annotation)
  local formatted = ("file: %s:%s\nannotation: %s"):format(annotation.filename or "", line_label(annotation), rendered_annotation_text(annotation))
  local hunk = hunk_text(annotation)

  if config.includeHunksOnCopy and hunk ~= "" then
    formatted = formatted .. "\nhunk:\n```\n" .. hunk .. "\n```"
  end

  return formatted
end

local function append_post_instruction(text, root)
  if not config.post_instruction or config.post_instruction == "" then
    return text
  end

  local result = text .. "\n\n---\n\n" .. config.post_instruction
  if root then
    result = result .. "\nannotations file: " .. annotations_path(root)
  end

  return result
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

local function wrapped_index(index, delta, count)
  return ((index - 1 + delta) % count) + 1
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

local function source_hunk(buf, line1, line2)
  local line_count = vim.api.nvim_buf_line_count(buf)
  if line_count == 0 then
    return ""
  end

  line1 = bounded(line1, 1, line_count)
  line2 = bounded(line2, 1, line_count)
  if line1 > line2 then
    line1, line2 = line2, line1
  end

  return table.concat(vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, false), "\n")
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

local function current_file_annotations()
  local path, is_diffview, use_diffview_virtual_filename = current_buffer_path()
  if not path then
    return nil
  end

  local root = repo_root(path)
  local filename = annotation_filename(path, root, is_diffview, use_diffview_virtual_filename)
  local annotations = read_annotations(root)
  if not annotations then
    return nil
  end

  local file_annotations = {}
  for _, annotation in ipairs(annotations) do
    if annotation.filename == filename then
      local start_line, end_line = line_range(annotation.linenumber)
      if start_line and end_line then
        table.insert(file_annotations, {
          start_line = start_line,
          end_line = end_line,
        })
      end
    end
  end

  table.sort(file_annotations, function(a, b)
    if a.start_line == b.start_line then
      return a.end_line < b.end_line
    end

    return a.start_line < b.start_line
  end)

  return file_annotations
end

local function jump_source_annotation(direction)
  local file_annotations = current_file_annotations()
  if not file_annotations then
    notify("Cannot navigate annotations from this buffer", vim.log.levels.WARN)
    return
  end

  if #file_annotations == 0 then
    notify("No annotations in current file", vim.log.levels.WARN)
    return
  end

  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local current_index
  local target_index

  for index, annotation in ipairs(file_annotations) do
    if current_line >= annotation.start_line and current_line <= annotation.end_line then
      current_index = index
      break
    end
  end

  if current_index then
    target_index = wrapped_index(current_index, direction, #file_annotations)
  elseif direction > 0 then
    for index, annotation in ipairs(file_annotations) do
      if annotation.start_line > current_line then
        target_index = index
        break
      end
    end
    target_index = target_index or 1
  else
    for index, annotation in ipairs(file_annotations) do
      if annotation.start_line < current_line then
        target_index = index
      else
        break
      end
    end
    target_index = target_index or #file_annotations
  end

  local line_count = vim.api.nvim_buf_line_count(0)
  pcall(vim.api.nvim_win_set_cursor, 0, { bounded(file_annotations[target_index].start_line, 1, line_count), 0 })
end

local function refresh_annotation_signs(buf, annotations, root)
  buf = buf or vim.api.nvim_get_current_buf()
  vim.fn.sign_unplace(sign_group, { buffer = buf })

  local path, is_diffview, use_diffview_virtual_filename = current_buffer_path(buf)
  if not path then
    return
  end

  root = root or repo_root(path)
  annotations = annotations or read_annotations(root)
  if not annotations then
    return
  end

  local filename = annotation_filename(path, root, is_diffview, use_diffview_virtual_filename)
  local line_count = vim.api.nvim_buf_line_count(buf)
  local signed_lines = {}

  vim.b[buf].annotate_source_annotations = annotations
  vim.b[buf].annotate_source_filename = filename
  vim.b[buf].annotate_source_root = root

  for _, annotation in ipairs(annotations) do
    if annotation.filename == filename then
      local start_line, end_line = line_range(annotation.linenumber)
      if start_line and end_line and end_line >= 1 and start_line <= line_count then
        local sign_line = bounded(start_line, 1, line_count)
        local resolved = annotation_resolved(annotation)
        if not signed_lines[sign_line] or (signed_lines[sign_line] == "resolved" and not resolved) then
          signed_lines[sign_line] = resolved and "resolved" or "unresolved"
        end
      end
    end
  end

  for sign_line, state in pairs(signed_lines) do
    local name = state == "resolved" and resolved_sign_name or sign_name
    vim.fn.sign_place(sign_line, sign_group, name, buf, { lnum = sign_line, priority = config.sign_priority })
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

local function valid_window(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function valid_buffer(buf)
  return buf and vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf)
end

local function close_list_window()
  if not valid_window(list_state.win) then
    list_state.win = nil
    return false
  end

  list_state.cursor = vim.api.nvim_win_get_cursor(list_state.win)
  pcall(vim.api.nvim_win_close, list_state.win, true)
  list_state.win = nil

  return true
end

local function source_context(opts)
  local path, is_diffview, use_diffview_virtual_filename = current_buffer_path()
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
    filename = annotation_filename(path, root, is_diffview, use_diffview_virtual_filename),
    linenumber = linenumber,
    hunk = source_hunk(0, line1, line2),
    resolved = false,
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
    hunk = context.hunk,
    resolved = context.resolved == true,
  }

  if context.meta then
    entry.meta = context.meta
  end

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
    ("Shortcuts: %s/%s navigate | %s toggle resolved | %s open source | %s copy annotation | %s copy all annotations | %s delete annotation"):format(
      config.list_keymaps.next,
      config.list_keymaps.previous,
      config.list_keymaps.toggle_resolved,
      config.list_keymaps.open,
      config.list_keymaps.copy,
      config.list_keymaps.copy_all,
      config.list_keymaps.delete
    ),
    "",
  }
  local line_map = {}
  local index_lines = {}
  local resolved_ranges = {}

  if #annotations == 0 then
    table.insert(lines, "No annotations.")
  else
    for index, annotation in ipairs(annotations) do
      local start_line = #lines + 1
      local annotation_lines = split_annotation_lines(rendered_annotation_text(annotation))
      local resolved = annotation_resolved(annotation)
      local checkbox = resolved and "- [x]" or "- [ ]"
      index_lines[index] = start_line

      table.insert(lines, ("%s file: %s:%s"):format(checkbox, annotation.filename or "", line_label(annotation)))
      table.insert(lines, "annotation: " .. annotation_lines[1])

      for i = 2, #annotation_lines do
        table.insert(lines, annotation_lines[i])
      end

      if resolved then
        table.insert(resolved_ranges, { start_line = start_line, end_line = #lines })
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

  for _, range in ipairs(resolved_ranges) do
    for line = range.start_line, range.end_line do
      vim.api.nvim_buf_add_highlight(buf, namespace, config.resolved_highlight, line - 1, 0, -1)
    end
  end

  vim.bo[buf].modified = false
  vim.bo[buf].modifiable = false
  vim.b[buf].annotate_root = root
  vim.b[buf].annotate_line_map = line_map
  vim.b[buf].annotate_index_lines = index_lines
  vim.b[buf].annotate_min_line = index_lines[1] or math.min(3, vim.api.nvim_buf_line_count(buf))
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

local function jump_list_annotation(buf, direction)
  local index_lines = vim.b[buf].annotate_index_lines or {}
  if #index_lines == 0 then
    notify("No annotations to navigate", vim.log.levels.WARN)
    return
  end

  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local current_index = (vim.b[buf].annotate_line_map or {})[current_line]
  local target_index

  if current_index then
    target_index = wrapped_index(current_index, direction, #index_lines)
  elseif direction > 0 then
    for index, line in ipairs(index_lines) do
      if line > current_line then
        target_index = index
        break
      end
    end
    target_index = target_index or 1
  else
    for index, line in ipairs(index_lines) do
      if line < current_line then
        target_index = index
      else
        break
      end
    end
    target_index = target_index or #index_lines
  end

  pcall(vim.api.nvim_win_set_cursor, 0, { index_lines[target_index], 0 })
end

local function clamp_list_cursor(buf)
  local min_line = vim.b[buf].annotate_min_line
  if not min_line then
    return
  end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  if line < min_line then
    pcall(vim.api.nvim_win_set_cursor, 0, { min_line, 0 })
  end
end

local function copy_current_annotation(buf)
  local annotation, _, _, root = list_annotation_at_cursor(buf)
  if not annotation then
    notify("No annotation at current line", vim.log.levels.WARN)
    return
  end

  if annotation_resolved(annotation) then
    notify("Annotation is resolved", vim.log.levels.WARN)
    return
  end

  copy_to_clipboard(append_post_instruction(formatted_annotation(annotation), root), "Copied annotation")
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
    if not annotation_resolved(annotation) then
      table.insert(formatted, formatted_annotation(annotation))
    end
  end

  if #formatted == 0 then
    notify("No unresolved annotations to copy", vim.log.levels.WARN)
    return
  end

  copy_to_clipboard(append_post_instruction(table.concat(formatted, "\n\n---\n\n"), root), "Copied unresolved annotations")
end

local function toggle_list_annotation_resolved(buf)
  local annotation, index, annotations, root = list_annotation_at_cursor(buf)
  if not annotation or not index then
    notify("No annotation at current line", vim.log.levels.WARN)
    return
  end

  local resolved = not annotation_resolved(annotation)
  annotations[index].resolved = resolved

  if write_annotations(root, annotations) then
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    refresh_annotation_signs_for_root(root)
    render_list(buf, root, annotations)
    local line_count = vim.api.nvim_buf_line_count(buf)
    pcall(vim.api.nvim_win_set_cursor, 0, { math.min(current_line, line_count), 0 })
    notify(resolved and "Annotation resolved" or "Annotation unresolved")
  end
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

local function diffview_buffer(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name:match("^diffview://") then
    return true
  end

  return vim.bo[buf].filetype:lower():match("^diffview") ~= nil
end

local function diffview_tab(tab)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if normal_window(win) and diffview_buffer(vim.api.nvim_win_get_buf(win)) then
      return true
    end
  end

  return false
end

local function find_normal_window_in_tab(tab, target_buf)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if normal_window(win) and (not target_buf or vim.api.nvim_win_get_buf(win) == target_buf) then
      return win
    end
  end

  return nil
end

local function find_normal_window_for_buffer(buf, opts)
  opts = opts or {}
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if not opts.exclude_diffview_tabs or not diffview_tab(tab) then
      local win = find_normal_window_in_tab(tab, buf)
      if win then
        return win
      end
    end
  end

  return nil
end

local function find_loaded_buffer(path)
  local target_path = vim.fn.fnamemodify(path, ":p")
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if vim.api.nvim_buf_is_loaded(buf) and name ~= "" and not name:match("^%a[%w+.-]*://") then
      if vim.fn.fnamemodify(name, ":p") == target_path then
        return buf
      end
    end
  end

  return nil
end

local function fallback_window(preferred_win, opts)
  opts = opts or {}
  if normal_window(preferred_win) then
    local tab = vim.api.nvim_win_get_tabpage(preferred_win)
    if not opts.exclude_diffview_tabs or not diffview_tab(tab) then
      return preferred_win
    end
  end

  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if not opts.exclude_diffview_tabs or not diffview_tab(tab) then
      local win = find_normal_window_in_tab(tab)
      if win then
        return win
      end
    end
  end

  return nil
end

local function use_target_window(target_win, create_tab)
  if target_win and vim.api.nvim_win_is_valid(target_win) then
    vim.api.nvim_set_current_win(target_win)
    return true
  end

  if create_tab then
    vim.cmd.tabnew()
    return true
  end

  return false
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

  local open_in_non_diffview_tab = vim.b[buf].annotate_source_is_diffview == true
  local window_opts = { exclude_diffview_tabs = open_in_non_diffview_tab }
  local target_buf = find_loaded_buffer(path)
  local target_win = target_buf and find_normal_window_for_buffer(target_buf, window_opts) or fallback_window(source_win, window_opts)

  if list_win and vim.api.nvim_win_is_valid(list_win) then
    pcall(vim.api.nvim_win_close, list_win, true)
  end

  use_target_window(target_win, open_in_non_diffview_tab)

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
  local path, is_diffview, use_diffview_virtual_filename = current_buffer_path()
  if not path then
    return nil, nil, nil, nil
  end

  local root = repo_root(path)
  local filename = annotation_filename(path, root, is_diffview, use_diffview_virtual_filename)
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
  local start_line, end_line = line_range(annotation.linenumber)
  local hunk = start_line and end_line and source_hunk(0, start_line, end_line) or hunk_text(annotation)
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
    hunk = hunk,
    resolved = annotation_resolved(annotation),
    meta = annotation.meta,
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
  if close_list_window() then
    return
  end

  local root = current_annotations_root()
  local annotations = read_annotations(root)
  if not annotations then
    return
  end

  local source_win = vim.api.nvim_get_current_win()
  local source_buf = vim.api.nvim_win_get_buf(source_win)
  local buf = list_state.buf

  if not valid_buffer(buf) then
    local uv = vim.uv or vim.loop

    buf = vim.api.nvim_create_buf(false, true)
    list_state.buf = buf

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "markdown"
    vim.api.nvim_buf_set_name(buf, "annotate://list/" .. uv.hrtime())
  end

  render_list(buf, root, annotations)
  vim.b[buf].annotate_source_is_diffview = source_is_diffview(source_buf)
  list_state.source_win = source_win
  list_state.win = open_float(buf, "Annotations")

  local cursor = list_state.cursor or { vim.b[buf].annotate_min_line or 1, 0 }
  pcall(vim.api.nvim_win_set_cursor, list_state.win, { math.min(cursor[1], vim.api.nvim_buf_line_count(buf)), 0 })

  local group = vim.api.nvim_create_augroup("joogie_annotate_list_" .. buf, { clear = true })
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    buffer = buf,
    callback = function()
      clamp_list_cursor(buf)
    end,
  })

  vim.keymap.set("n", config.list_keymaps.next, function()
    jump_list_annotation(buf, 1)
  end, { buffer = buf, desc = "Next annotation" })

  vim.keymap.set("n", config.list_keymaps.previous, function()
    jump_list_annotation(buf, -1)
  end, { buffer = buf, desc = "Previous annotation" })

  vim.keymap.set("n", config.list_keymaps.toggle_resolved, function()
    toggle_list_annotation_resolved(buf)
  end, { buffer = buf, desc = "Toggle annotation resolved" })

  vim.keymap.set("n", config.list_keymaps.open, function()
    if valid_window(list_state.win) then
      list_state.cursor = vim.api.nvim_win_get_cursor(list_state.win)
    end

    open_source_annotation(buf, list_state.win, list_state.source_win)
    if not valid_window(list_state.win) then
      list_state.win = nil
    end
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

function M.copy()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].annotate_line_map then
    copy_current_annotation(buf)
    return
  end

  local annotation, _, _, root = source_annotation_at_cursor()
  if not annotation then
    notify("No annotation at current line", vim.log.levels.WARN)
    return
  end

  if annotation_resolved(annotation) then
    notify("Annotation is resolved", vim.log.levels.WARN)
    return
  end

  copy_to_clipboard(append_post_instruction(formatted_annotation(annotation), root), "Copied annotation")
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

function M.gh_comments(opts)
  if vim.fn.executable("gh") ~= 1 then
    notify("gh executable not found", vim.log.levels.ERROR)
    return
  end

  local root = current_annotations_root()
  local annotations = read_annotations(root)
  if not annotations then
    return
  end

  local pr = opts and opts.fargs and opts.fargs[2]
  if not pr or pr == "" then
    pr = gh_pr_number(root)
  end

  if not pr then
    return
  end

  notify("Fetching GitHub PR comments for #" .. pr)

  local comments = gh_review_comments(root, pr)
  if not comments then
    return
  end

  local previous_resolved = gh_imported_annotations(annotations)
  local next_annotations = keep_non_gh_annotations(annotations)
  local imported = 0
  local skipped = 0

  for _, comment in ipairs(comments) do
    local annotation = gh_comment_annotation(comment, previous_resolved, pr)
    if annotation then
      table.insert(next_annotations, annotation)
      imported = imported + 1
    else
      skipped = skipped + 1
    end
  end

  if write_annotations(root, next_annotations) then
    refresh_annotation_signs_for_root(root)

    local buf = vim.api.nvim_get_current_buf()
    if vim.b[buf].annotate_line_map then
      render_list(buf, root, next_annotations)
    end

    local message = ("Imported %d GitHub PR comment%s"):format(imported, imported == 1 and "" or "s")
    if skipped > 0 then
      message = message .. (" (%d skipped)"):format(skipped)
    end

    notify(message)
  end
end

function M.previous()
  jump_source_annotation(-1)
end

function M.next()
  jump_source_annotation(1)
end

vim.api.nvim_create_user_command("Annotate", function(opts)
  local command = opts.fargs[1]

  if command == "add" then
    M.add(opts)
  elseif command == "copy" then
    M.copy()
  elseif command == "list" then
    M.list()
  elseif command == "delete" then
    M.delete()
  elseif command == "deleteall" then
    M.deleteall()
  elseif command == "gh_comments" then
    M.gh_comments(opts)
  else
    notify("Usage: :Annotate add|copy|list|delete|deleteall|gh_comments", vim.log.levels.WARN)
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
vim.keymap.set("n", config.keymaps.copy, "<cmd>Annotate copy<cr>", { desc = "Copy annotation" })
vim.keymap.set("n", config.keymaps.list, "<cmd>Annotate list<cr>", { desc = "List annotations" })
vim.keymap.set("n", config.keymaps.delete, "<cmd>Annotate delete<cr>", { desc = "Delete annotation" })
vim.keymap.set("n", config.keymaps.delete_all, "<cmd>Annotate deleteall<cr>", { desc = "Delete all annotations" })
vim.keymap.set("n", config.keymaps.gh_comments, "<cmd>Annotate gh_comments<cr>", { desc = "Import GitHub PR comments" })
vim.keymap.set("n", config.keymaps.previous, M.previous, { desc = "Previous annotation" })
vim.keymap.set("n", config.keymaps.next, M.next, { desc = "Next annotation" })

return M
