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
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "z"
        "aws"
        "fnm"
        "git"
        "tmux"
        "docker"
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
      python = "python3";
      pip = "pip3";
    };

    initContent= ''
export DISABLE_AUTO_UPDATE="true"

bindkey -M viins jj vi-cmd-mode
export VI_MODE_SET_CURSOR=true
# oh-my-zsh end

# variables
# export TERM=xterm-256color
export EDITOR=nvim
export MANPAGER='nvim +Man!'
export PATH=$PATH:/opt/homebrew/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.local/share/fnm
export PATH=$PATH:$HOME/.local/custom/bin
export PATH=$PATH:$HOME/.local/share/bob/nvim-bin
export PATH=$PATH:$HOME/.duckdb/cli/latest

if [[ -f "$HOME/.private.sh" ]]; then
  source "$HOME/.private.sh"
fi
# variables end

# fnm
eval "$(fnm env --use-on-cd --shell zsh)"
# fnm end

# bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# bun end
    '';
  };
}

