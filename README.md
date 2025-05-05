# dotfiles

Personal dotfiles with nix

![sc1](https://github.com/user-attachments/assets/e11bd0a0-a0d5-4c65-b16c-2dd24cccb71d)
![sc2](https://github.com/user-attachments/assets/42975532-19ab-4f16-9d44-a6500c839297)
![sc3](https://github.com/user-attachments/assets/43d1f26c-6708-4e55-bb11-e24283d79bc8)
![sc4](https://github.com/user-attachments/assets/5747dd30-eac5-4244-b374-4f13eddc9fde)


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
