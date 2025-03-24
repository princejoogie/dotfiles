# dotfiles

personal dotfiles with nix

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
