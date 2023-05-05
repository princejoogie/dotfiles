local schemastore = require("schemastore")

if not schemastore then
	return
end

return {
	settings = {
		json = {
			schemas = schemastore.json.schemas(),
			validate = { enable = true },
		},
	},
}
