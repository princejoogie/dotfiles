local plugins_path = vim.fn.stdpath("data") .. "/site/pack/packer/start"
local dir_list = vim.fn.glob(plugins_path .. "/*", true, true)
local library_table = {}

for _, v in ipairs(dir_list) do
	library_table[v .. "/lua"] = true
end

library_table[vim.fn.expand("$VIMRUNTIME/lua")] = true
library_table[vim.fn.stdpath("config") .. "/lua"] = true

return {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = library_table,
			},
		},
	},
}
