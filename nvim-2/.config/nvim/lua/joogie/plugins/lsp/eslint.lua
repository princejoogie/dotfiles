local lspconfig_util = require("lspconfig.util")

return {
	root_dir = lspconfig_util.find_git_ancestor,
}
