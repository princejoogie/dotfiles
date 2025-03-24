local find_git_root = require("joogie.utils").find_git_root

return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    opts = {
      provider = "claude",
      file_selector = { provider = "snacks" },
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-5-sonnet-20241022",
        temperature = 0,
        max_tokens = 4096,
      },
      system_prompt = function()
        local hub = require("mcphub").get_hub_instance()
        return hub:get_active_servers_prompt()
      end,
      -- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
      custom_tools = function()
        return {
          require("mcphub.extensions.avante").mcp_tool(),
        }
      end,
    },
    build = "make",
    dependencies = {
      "stevearc/dressing.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "ravitemer/mcphub.nvim",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
      {
        "ravitemer/mcphub.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        build = "npm install -g mcp-hub@latest",
        cmd = { "McpHub" },
        config = function()
          local port = 9999
          local config = find_git_root() .. "/mcpservers.json"
          require("mcphub").setup({
            port = port,
            config = config,
            log = {
              level = vim.log.levels.WARN,
              to_file = false,
              file_path = nil,
              prefix = "MCPHub",
            },
          })

          local cmd = "mcp-hub"
          local args = { "--port", tostring(port), "--config", config }

          local handle
          handle = vim.uv.spawn(cmd, {
            args = args,
            stdio = { nil, nil, nil }, -- optionally capture stdio
            detached = true,
          }, function(code, signal)
            vim.schedule(function()
              Snacks.notifier("mcp-hub exited with code " .. code .. ", signal " .. signal)
            end)
            handle:close()
          end)

          if not handle then
            vim.notify("Failed to start mcp-hub", vim.log.levels.ERROR)
          else
            vim.uv.unref(handle)
          end
        end,
      },
    },
  },
}
