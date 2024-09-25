# https://daiderd.com/nix-darwin/manual/index.html
{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.vim
      ];

      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;
      nix.settings.experimental-features = "nix-command flakes";
      programs.zsh.enable = true;  # default shell on catalina
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 5;

      system.defaults = {
        dock.autohide = true;
        dock.mru-spaces = true;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        finder.ShowPathbar = true;
      };

      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    darwinConfigurations."princejoogie-macos" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
    darwinPackages = self.darwinConfigurations."princejoogie-macos".pkgs;
  };
}
