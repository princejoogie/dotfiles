call plug#begin(stdpath('data'))

" QOL
Plug 'AndrewRadev/tagalong.vim'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
Plug 'MunifTanjim/nui.nvim'
Plug 'ThePrimeagen/harpoon'
Plug 'akinsho/toggleterm.nvim'
Plug 'djoshea/vim-autoread'
Plug 'folke/todo-comments.nvim'
Plug 'github/copilot.vim'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/gv.vim'
Plug 'justinmk/vim-sneak'
Plug 'kdheepak/lazygit.nvim'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'lewis6991/gitsigns.nvim'
Plug 'lewis6991/impatient.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'mhartington/formatter.nvim'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'numToStr/Comment.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-telescope/telescope-github.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
Plug 'princejoogie/tailwind-highlight.nvim', {'branch': 'dev'}
Plug 'ray-x/lsp_signature.nvim'
Plug 'rcarriga/nvim-notify'
Plug 'romgrk/barbar.nvim'
Plug 'ryanoasis/vim-devicons'
Plug 'stevearc/dressing.nvim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vuki656/package-info.nvim'
Plug 'windwp/nvim-ts-autotag'

" Debugging
Plug 'mfussenegger/nvim-dap'
Plug 'nvim-telescope/telescope-dap.nvim'
Plug 'rcarriga/nvim-dap-ui'
Plug 'theHamsta/nvim-dap-virtual-text'

" LSP
Plug 'arkav/lualine-lsp-progress'
Plug 'b0o/schemastore.nvim'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-emoji'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/nvim-cmp', {'branch': 'dev'}
Plug 'hrsh7th/vim-vsnip'
Plug 'jose-elias-alvarez/null-ls.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'onsails/lspkind-nvim'
Plug 'williamboman/nvim-lsp-installer'

call plug#end()
