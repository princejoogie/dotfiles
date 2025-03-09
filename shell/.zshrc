# oh-my-zsh
export DISABLE_AUTO_UPDATE="true"

export ZSH="$HOME/.oh-my-zsh"

plugins=(
  z
  tmux
  vi-mode
  zsh-autosuggestions
  zsh-syntax-highlighting
  fast-syntax-highlighting
  zsh-autocomplete
)

bindkey -M viins jj vi-cmd-mode
export VI_MODE_SET_CURSOR=true
# oh-my-zsh end

# aliases
alias cls=clear
alias so=source
alias x=exit
alias G=git
alias t=tmux
# alises end

# variables
export EDITOR=nvim
export NVIM_DATA=$HOME/.local/share/nvim
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.local/share/fnm
export PATH=$PATH:$HOME/.local/share/bob/nvim-bin
export PATH=$PATH:/opt/homebrew/bin

if [[ -f "$HOME/.private.sh" ]]; then
  source "$HOME/.private.sh"
fi
# variables end

# starship
eval "$(starship init zsh)"
# starship end

# fnm
eval "$(fnm env --use-on-cd --shell zsh)"
# fnm end

# miniconda
export MINICONDA_INSTALL="$HOME/miniconda3"
if [[ -f $MINICONDA_INSTALL ]]; then
  export PATH="$MINICONDA_INSTALL/bin:$PATH"
  . "$MINICONDA_INSTALL/etc/profile.d/conda.sh"
fi
# miniconda end

source $ZSH/oh-my-zsh.sh
