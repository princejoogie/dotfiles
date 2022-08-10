local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
local is_bootstrap = false

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

return require("packer").startup(
  function(use)
    use "wbthomason/packer.nvim"
    use "folke/tokyonight.nvim"
    use "nvim-lua/plenary.nvim"

    -- General
    use "AndrewRadev/tagalong.vim"
    use "MunifTanjim/nui.nvim"
    use "akinsho/toggleterm.nvim"
    use "djoshea/vim-autoread"
    use "folke/todo-comments.nvim"
    use "github/copilot.vim"
    use "jiangmiao/auto-pairs"
    use "junegunn/gv.vim"
    use "justinmk/vim-sneak"
    use "kyazdani42/nvim-tree.lua"
    use "kyazdani42/nvim-web-devicons"
    use "lewis6991/impatient.nvim"
    use "lukas-reineke/indent-blankline.nvim"
    use "mhartington/formatter.nvim"
    use "norcalli/nvim-colorizer.lua"
    use "numToStr/Comment.nvim"
    use "nvim-lua/popup.nvim"
    use "princejoogie/tailwind-highlight.nvim"
    use "ray-x/lsp_signature.nvim"
    use "romgrk/barbar.nvim"
    use "ryanoasis/vim-devicons"
    use "segeljakt/vim-silicon"
    use "stevearc/dressing.nvim"
    use "tpope/vim-fugitive"
    use "tpope/vim-repeat"
    use "tpope/vim-rhubarb"
    use "tpope/vim-surround"
    use "tpope/vim-unimpaired"
    use "vuki656/package-info.nvim"
    use "yamatsum/nvim-cursorline"

    use {"JoosepAlviste/nvim-ts-context-commentstring", requires = {"nvim-treesitter/nvim-treesitter"}}
    use {"ThePrimeagen/harpoon", requires = {"nvim-lua/plenary.nvim"}}
    use {"iamcco/markdown-preview.nvim", run = "cd app && npm install", cmd = "MarkdownPreview"}
    use {"lewis6991/gitsigns.nvim", requires = {"nvim-lua/plenary.nvim"}}
    use {"nvim-lualine/lualine.nvim", requires = {"vuki656/package-info.nvim"}}
    use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"}
    use {"nvim-treesitter/playground", requires = {"nvim-treesitter/nvim-treesitter"}}
    use {"tpope/vim-dispatch", opt = true, cmd = {"Dispatch", "Make", "Focus", "Start"}}

    use {
      "windwp/nvim-ts-autotag",
      config = function()
        require("nvim-ts-autotag").setup()
      end
    }
    use {
      "nvim-telescope/telescope.nvim",
      requires = {"nvim-lua/plenary.nvim", "nvim-telescope/telescope-dap.nvim", "nvim-telescope/telescope-github.nvim"}
    }
    use {
      "rcarriga/nvim-notify",
      config = function()
        local notify = require("notify")
        notify.setup({background_colour = "#000000", fps = 60})
        vim.notify = notify
      end
    }

    -- Debugging
    use "rcarriga/nvim-dap-ui"
    use "theHamsta/nvim-dap-virtual-text"
    use "mfussenegger/nvim-dap"

    -- LSP
    use "arkav/lualine-lsp-progress"
    use "b0o/schemastore.nvim"
    use "hrsh7th/vim-vsnip"
    use "jose-elias-alvarez/null-ls.nvim"
    use "neovim/nvim-lspconfig"
    use "onsails/lspkind-nvim"
    use "williamboman/nvim-lsp-installer"
    use {"hrsh7th/cmp-vsnip", requires = {"onsails/lspkind-nvim"}}

    use {
      "hrsh7th/nvim-cmp",
      requires = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-emoji",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-vsnip"
      }
    }

    if is_bootstrap then
      require("packer").sync()
    end
  end
)
