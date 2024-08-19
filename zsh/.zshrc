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

if [[ -d "/opt/homebrew/share/zsh/site-functions" ]]; then
  fpath+=/opt/homebrew/share/zsh/site-functions
fi

export EDITOR=nvim
export NVIM_DATA=$HOME/.local/share/nvim

export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.local/share/bob/nvim-bin
export PATH=$PATH:/usr/local/go/bin

case `uname` in
  Linux)
    # miniconda
    export MINICONDA_INSTALL="$HOME/miniconda3"
    export PATH="$MINICONDA_INSTALL/bin:$PATH"
    . "$MINICONDA_INSTALL/etc/profile.d/conda.sh"
    # miniconda end
  ;;
  Darwin)
    # miniconda
    export MINICONDA_INSTALL="$HOME/miniconda3"
    export PATH="$MINICONDA_INSTALL/bin:$PATH"
    . "$MINICONDA_INSTALL/etc/profile.d/conda.sh"
    # miniconda end
  ;;
esac

export ZSH="$HOME/.oh-my-zsh"

CASE_SENSITIVE="false"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# git
plugins=(
  z
  tmux
  vi-mode
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# Configurations
bindkey -M viins jj vi-cmd-mode
export VI_MODE_SET_CURSOR=true

HISTFILE="$HOME/.zsh_history"
setopt BANG_HIST
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"

# Aliases
alias cls=clear
alias so=source
alias x=exit
alias G=git
alias vim=nvim
alias t=tmux
alias ldock=lazydocker

# starship
eval "$(starship init zsh)"
# starship end

# fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)"
# fnm end

# deno
if [ -d "$HOME/.deno" ]; then
  export DENO_INSTALL="$HOME/.deno"
  export PATH="$DENO_INSTALL/bin:$PATH"
fi
# deno end

if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zprof
fi
