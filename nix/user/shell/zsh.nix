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
      lta = "ls -lta --human-readable";
    };

    initContent= ''
export DISABLE_AUTO_UPDATE="true"

bindkey -M viins jj vi-cmd-mode
export VI_MODE_SET_CURSOR=true
# oh-my-zsh end

# options
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
# options end

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
export PATH=$PATH:/opt/homebrew/opt/libpq/bin

if [[ -f "$HOME/.private.sh" ]]; then
  source "$HOME/.private.sh"
fi
# variables end

# fnm
eval "$(fnm env --use-on-cd --shell zsh)"
# fnm end

# uv
if [[ -x "$(command -v uv)" ]]; then
  eval "$(uv generate-shell-completion zsh)"
fi

if [[ -x "$(command -v uvx)" ]]; then
  eval "$(uvx --generate-shell-completion zsh)"
fi
# uv end

# direnv
if [[ -x "$(command -v direnv)" ]]; then
  eval "$(direnv hook zsh)"
fi
# direnv end

# bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# bun end
    '';
  };
}

