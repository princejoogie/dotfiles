# dotfiles

my dotfiles config

## NVIM

### Prerequisutes 

- [x] [vim-plug](https://github.com/junegunn/vim-plug)
- [x] ripgrep
- [x] fzf
- [x] fd

```bash
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim-data/site/autoload/plug.vim" -Force
```

```bash
rm -rf "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim" && `
ln -s "$pwd/nvim" "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/"
```

**Notes**

- [null-ls setup](https://jose-elias-alvarez.medium.com/configuring-neovims-lsp-client-for-typescript-development-5789d58ea9c)
