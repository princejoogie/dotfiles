# dotfiles

![nvim_preview](https://user-images.githubusercontent.com/47204120/170640452-607474b9-32de-464f-a366-5343073f2b51.jpg)

## Usage

```bash
git clone https://github.com/princejoogie/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### Installation

```bash
chmod +x install
./install
```

### Clean

```bash
chmod +x clean
./clean
```

---

### NVIM

#### Prerequisutes

- [x] [vim-plug](https://github.com/junegunn/vim-plug)
- [x] [ripgrep](https://github.com/BurntSushi/ripgrep)
- [x] [fzf](https://github.com/junegunn/fzf)
- [x] [fd](https://github.com/sharkdp/fd)

> run `:checkhealth` to see remaining dependencies


<!-- ![nvim_preview](https://user-images.githubusercontent.com/47204120/160265678-c9218945-cfa1-449e-9898-2a5abe15c67e.png) -->

**DAP Configuration**


- Node

```bash
git clone https://github.com/microsoft/vscode-node-debug2.git "$HOME/.local/share/nvim/vscode-node-debug2"
cd "$HOME/.local/share/nvim/vscode-node-debug2"
npm install
npm run build
```

- C++/C/Rust (via lldb)

```bash
sudo apt install lldb
```

### ZSH

#### Prerequisutes

- [x] [zsh-snap](https://github.com/marlonrichert/zsh-snap)
- [x] [powerlevel10k](https://github.com/romkatv/powerlevel10k)



![WindowsTerminal_agA6SNyJoN](https://user-images.githubusercontent.com/47204120/170641003-4a40b00b-bb89-45f4-9d2a-da78b8bb7019.jpg)

<!-- ![zsh preview] -->

### TMUX

Cheat Sheet

| Command     | Description                                    |
| ----------- | ---------------------------------------------- |
| `Ctrl+a c`  | Create a new window (with shell)               |
| `Ctrl+a w`  | Choose window from a list                      |
| `Ctrl+a s`  | Choose session from a list                     |
| `Ctrl+a 0`  | Switch to window 0 (by number)                 |
| `Ctrl+a ,`  | Rename the current window                      |
| `Ctrl+a \|` | Split current pane horizontally into two panes |
| `Ctrl+a -`  | Split current pane vertically into two panes   |
| `Ctrl+a o`  | Go to the next pane                            |
| `Ctrl+a ;`  | Toggle between the current and previous pane   |
| `Ctrl+a x`  | Close the current pane                         |
| `M+Left`    | Switch to left pane                            |
| `M+Right`   | Switch to right pane                           |
| `M+Up`      | Switch to up pane                              |
| `M+Down`    | Switch to down pane                            |

[nvim thumbnail]: https://user-images.githubusercontent.com/47204120/157621808-7ff30e77-d579-4879-8aab-8e1bafeac2ad.jpg
[nvim preview]: https://user-images.githubusercontent.com/47204120/157621486-7138e25c-c288-4e28-b30f-c2896bff48b1.mp4
[zsh preview]: https://user-images.githubusercontent.com/47204120/157621589-874a711f-8771-4917-9ed0-f3f5a0feb439.jpg
[skhd]: https://github.com/koekeishiya/skhd
[yabai]: https://github.com/koekeishiya/yabai
[simple bar]: https://github.com/Jean-Tinland/simple-bar
