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
    autostart = false,
    hide_up_to_date = true,
    hide_unstable_versions = false
  }
)
