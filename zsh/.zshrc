if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zmodload zsh/zprof
fi

# Variables
if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi

if [[ -f "$HOME/.private.sh" ]]; then
  source "$HOME/.private.sh"
fi

if [[ -f "$HOME/.functions.sh" ]]; then
  source "$HOME/.functions.sh"
fi

if [[ -d "/opt/homebrew/share/zsh/site-functions" ]]; then
  fpath+=/opt/homebrew/share/zsh/site-functions
fi

if [[ -f "$HOME/completions/docker.sh" ]] then
  source "$HOME/completions/docker.sh" 
fi

if [[ -d "$HOME/.zsh/completion" ]] then
  fpath+="$HOME/.zsh/completion"
  autoload -Uz compinit && compinit
fi

# export DOTNET_ROOT="/opt/homebrew/Cellar/dotnet/8.0.0"
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$HOME/.dotnet
export TURBO_UI=1

export EDITOR=nvim
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.local/share/bob/nvim-bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.dotnet/tools
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
    export PATH=$PATH:/opt/homebrew/opt/libpq/bin

    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/platform-tools
    export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
    export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:"$(brew --prefix)/opt/libgit2/lib":"$(brew --prefix)/lib"

    # miniconda
    export MINICONDA_INSTALL="$HOME/miniconda3"
    export PATH="$MINICONDA_INSTALL/bin:$PATH"
    . "$MINICONDA_INSTALL/etc/profile.d/conda.sh"
    # miniconda end
  ;;
esac

export ZSH="$HOME/.oh-my-zsh"

# ZSH_TMUX_AUTOSTART=true
CASE_SENSITIVE="false"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# git
plugins=(
  tmux
  z
  vi-mode
  direnv
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# Configurations
bindkey -M viins jj vi-cmd-mode
export VI_MODE_SET_CURSOR=true

HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000
setopt BANG_HIST
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"

# Aliases
alias cls=clear
alias so=source
alias x=exit
alias e=echo
alias cl="xclip -selection c"
alias G=git
alias python=python3
alias pip=pip3
alias vim=nvim
alias t=tmux
alias ldock=lazydocker
alias hawk=git
alias tuah=push

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

if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zprof
fi
