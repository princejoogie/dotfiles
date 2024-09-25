{ pkgs, ... }:
{
  home.packages = with pkgs; [
    vscode
  ];
  home.file."/Library/Application Support/Code/User".source = ./.;
  home.file."/Library/Application Support/Code/User".recursive = true;
}
