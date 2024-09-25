{ pkgs, ... }:
{
  home.username = "prince.juguilon";
  home.homeDirectory = "/Users/prince.juguilon";
  home.stateVersion = "24.05";
  
  home.packages = with pkgs; [
    shortcat
    discord
    spotify
    appcleaner
    slack
  ];

  imports = [
    ./user/shell/zsh.nix
    ./user/shell/bin.nix
    ./user/nvim/nvim.nix
    ./user/kitty/kitty.nix
    ./user/vscode/vscode.nix
  ];
}
