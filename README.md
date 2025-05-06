# dotfiles

Personal dotfiles with nix

![sc1](https://github.com/user-attachments/assets/a129c2cb-e0a0-420b-b8bf-aa79c05728eb)
![sc2](https://github.com/user-attachments/assets/af4f3786-5444-464f-b639-ffa916ebbb0c)

## Usage

- Install [`nix`](https://nixos.org/download)
- Install [`nix-darwin`](https://github.com/LnL7/nix-darwin?tab=readme-ov-file#flakes) (flakes)
- Install [`home-manager`](https://nix-community.github.io/home-manager/index.xhtml#sec-install-nix-darwin-module) (darwin module)
- Clone this repo
  ```sh
  git clone https://github.com/princejoogie/dotfiles.git ~/dotfiles
  ```
- Run `darwin-rebuild switch` to switch to the flake
  ```sh
  darwin-rebuild switch --flake ~/dotfiles/nix
  ```
