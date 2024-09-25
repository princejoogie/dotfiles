{ pkgs, ... }:
{
  home.username = "prince.juguilon";
  home.homeDirectory = "/Users/prince.juguilon";

  home.packages = with pkgs; [
    awscli2
    direnv
    fnm
    lazydocker
    rustup
    starship
  ];

  home.stateVersion = "24.05";

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "tmux"
        "z"
        "vi-mode"
      ];
    };

    shellAliases = {
      cls = "clear";
      so = "source";
      x = "exit";
      G = "git";
      vim = "nvim";
      t = "tmux";
      ldock = "lazydocker";
    };

    initExtra = ''
	if [[ -f "$HOME/.private.sh" ]]; then
	  source "$HOME/.private.sh"
	fi

	export EDITOR=nvim
	export NVIM_DATA=$HOME/.local/share/nvim
	export PATH=$PATH:$HOME/.cargo/bin
	export PATH=$PATH:$HOME/.local/bin
	export PATH=$PATH:$HOME/.local/share/bob/nvim-bin
	export JOOGIE="qweqweqwe"

        # fnm
	export PATH="$HOME/.local/share/fnm:$PATH"
	eval "$(fnm env)"
        # fnm end

	bindkey -M viins jj vi-cmd-mode
	export VI_MODE_SET_CURSOR=true
    '';
  };

}
