{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    direnv
    ffmpeg
    fnm
    fzf
    gh
    lazydocker
    rustup
    starship
    tree
  ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  home.file.".config/starship.toml".source = ./starship.toml;
  home.file.".tmux.conf".source = ./.tmux.conf;
  home.file.".gitconfig".source = ./.gitconfig;

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
      export DISABLE_AUTO_UPDATE="true"

      if [[ -f "$HOME/.private.sh" ]]; then
        source "$HOME/.private.sh"
      fi

      # Function to check for .shell.sh and execute it
      check_and_run_shell_script() {
          if [ -f "$PWD/.shell.sh" ]; then
              source "$PWD/.shell.sh"
          fi
      }
      # Hook the function to the chpwd (change directory) hook
      chpwd_functions+=("check_and_run_shell_script")
      check_and_run_shell_script

      export EDITOR=nvim
      export NVIM_DATA=$HOME/.local/share/nvim
      export PATH=$PATH:$HOME/.cargo/bin
      export PATH=$PATH:$HOME/.local/bin
      export PATH=$PATH:$HOME/.local/share/bob/nvim-bin
      export PATH=$PATH:/opt/homebrew/opt/libpq/bin
      export PATH=$PATH:/opt/homebrew/bin
      export JOOGIE="qweqweqwe"

      # miniconda
      export MINICONDA_INSTALL="$HOME/miniconda3"
      export PATH="$MINICONDA_INSTALL/bin:$PATH"
      . "$MINICONDA_INSTALL/etc/profile.d/conda.sh"
      # miniconda end

      # fnm
      export PNPM_HOME="/home/joogie/.local/share/pnpm"
      case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
      esac

      export PATH="$HOME/.local/share/fnm:$PATH"
      eval "$(fnm env --use-on-cd)"
      # fnm end

      bindkey -M viins jj vi-cmd-mode
      export VI_MODE_SET_CURSOR=true
    '';
  };
}

