local package = require("package-info")

package.setup(
  {
    colors = {
      up_to_date = "#637777",
      outdated = "#637777"
    },
    icons = {
      enable = true,
      style = {
        -- up_to_date = "=> ",
        -- outdated = "=> "
        up_to_date = "|  ",
        outdated = "|  "
      }
    },
    autostart = true,
    hide_up_to_date = false,
    hide_unstable_versions = false
  }
)
