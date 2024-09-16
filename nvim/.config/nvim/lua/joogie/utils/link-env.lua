local M = {}

function M.expand(path)
	local home = os.getenv("HOME") or os.getenv("USERPROFILE")
	return path:gsub("^~", home)
end

function M.file_exists(file)
	local f = io.open(file, "rb")
	if f then
		f:close()
	end
	return f ~= nil
end

function M.read_file(file)
	if not M.file_exists(file) then
		print("file does not exist")
		return "[]"
	end
	local lines = ""
	for line in io.lines(file) do
		lines = lines .. line
	end
	return lines
end

---@param path string
---@return { filename: string, target: string }[]
function M.read_config(path)
	local file = M.expand(path)
	local lines = M.read_file(file)
	local json = vim.json.decode(lines)
	return json
end

function M.get_root_bare_repo_path(path)
	local cmd = { "git", "rev-parse", "--git-common-dir" }
	local output = ""
	local job_id = vim.fn.jobstart(cmd, {
		cwd = M.expand(path),
		on_stdout = function(_, lines)
			for _, line in ipairs(lines) do
				output = output .. line:gsub("\n", ""):gsub("\r", "")
			end
		end,
	})
	vim.fn.jobwait({ job_id })
	return output
end

---@param worktree_path string
function M.link(worktree_path)
	local bare_repo_path = M.get_root_bare_repo_path(worktree_path)
	local branch = M.expand(worktree_path):gsub(bare_repo_path .. "/", "")

	local config = M.read_config(bare_repo_path .. "/envs/config.json")

	for _, env in ipairs(config) do
		local _source = M.expand(bare_repo_path .. "/envs/" .. env.filename)
		local _target = M.expand(bare_repo_path .. "/" .. branch .. "/" .. env.target)
		local cmd = "ln -s " .. _source .. " " .. _target
		vim.fn.jobstart(cmd, { cwd = bare_repo_path })
	end
end

return M
