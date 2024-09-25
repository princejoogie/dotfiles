# https://daiderd.com/nix-darwin/manual/index.html
{
  description = "nix-darwin configuration for princejoogie";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    system = "aarch64-darwin";
    pkgs = import nixpkgs { inherit system; };
    systemConfig = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        tmux
        ripgrep
      ];

      nix.settings.experimental-features = "nix-command flakes";
      programs.zsh.enable = true;
      services.nix-daemon.enable = true;
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 5;

      users.users."prince.juguilon" = {
        name = "prince.juguilon";
        home = "/Users/prince.juguilon";
      };

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
        brews = [];
        casks = [
          "alacritty"
          "miniconda"
        ];
      };

      nixpkgs.hostPlatform = system;
    };
  in
  {
    darwinConfigurations."princejoogie-macos" = nix-darwin.lib.darwinSystem {
      inherit system pkgs;
      modules = [
        systemConfig
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.users."prince.juguilon" = ./home.nix;
        }
      ];
    };
  };
}
