{ ... }:
{
  home.username = "prince.juguilon";
  home.homeDirectory = "/Users/prince.juguilon";
  home.stateVersion = "24.05";

  imports = [
    ./user/shell/zsh.nix
    ./user/nvim/nvim.nix
    ./user/kitty/kitty.nix
    ./user/vscode/vscode.nix
  ];
}
