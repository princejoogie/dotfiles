# https://daiderd.com/nix-darwin/manual/index.html
{
  description = "nix-darwin configuration for princejoogie";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.awscli2
        pkgs.direnv
        pkgs.fnm
      ];

      nix.settings.experimental-features = "nix-command flakes";
      programs.zsh.enable = true;
      services.nix-daemon.enable = true;
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 5;

      system.defaults = {
        dock.autohide = true;
        dock.mru-spaces = true;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        finder.ShowPathbar = true;
      };

      homebrew = {
        brewPrefix = if pkgs.stdenv.hostPlatform.isAarch64 then "/opt/homebrew/bin" else "/usr/local";
        enable = true;
        brews = [
        ];
        casks = [
          "alacritty"
        ];
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
