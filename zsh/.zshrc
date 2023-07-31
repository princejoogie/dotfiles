# Variables
source "$HOME/.cargo/env"

if [[ -f "$HOME/.private.sh" ]]; then
  source "$HOME/.private.sh"
fi

export EDITOR=nvim
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.local/share/bob/nvim-bin
export PATH=$PATH:$HOME/.cargo/bin
export NVIM_DATA=$HOME/.local/share/nvim
# export LD_LIBRARY_PATH=/usr/lib/wsl/lib:$LD_LIBRARY_PATH

case `uname` in
  Linux)
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
    export PATH=$PATH:$JAVA_HOME/bin

    export ANDROID_HOME=$HOME/Android/Sdk
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/platform-tools
    export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

    export FLYCTL_INSTALL="$HOME/.fly"
    export PATH="$FLYCTL_INSTALL/bin:$PATH"

    # miniconda
    export MINICONDA_INSTALL="$HOME/miniconda3"
    export PATH="$MINICONDA_INSTALL/bin:$PATH"
    . "$MINICONDA_INSTALL/etc/profile.d/conda.sh"
    # miniconda end
  ;;
  Darwin)
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PYTHON_PATH=$HOME/Library/Python/3.9/bin
    export PATH=$PATH:$PYTHON_PATH
    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/platform-tools
    export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

    # miniconda
    export MINICONDA_INSTALL="$HOME/miniconda3"
    export PATH="$MINICONDA_INSTALL/bin:$PATH"
    . "$MINICONDA_INSTALL/etc/profile.d/conda.sh"
    # miniconda end
  ;;
esac


# ZSH_TMUX_AUTOSTART=true
CASE_SENSITIVE="false"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

plugins=(
	git
	tmux
	z
	vi-mode
  direnv
  zsh-autosuggestions
)

# Configurations
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"

# Aliases
alias cls=clear
alias so=source
alias x=exit
alias e=echo
alias cl="xclip -selection c"
alias python=python3
alias pip=pip3
alias vim=nvim

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# starship
eval "$(starship init zsh)"
# starship end

# pnpm
export PNPM_HOME="/home/joogie/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)"
# fnm end

# deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
# deno end
