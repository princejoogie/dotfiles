# oh-my-zsh
export DISABLE_AUTO_UPDATE="true"

export ZSH="$HOME/.oh-my-zsh"

plugins=(
  z
  tmux
  aws
  docker
  vi-mode
  zsh-autosuggestions
  zsh-syntax-highlighting
  fast-syntax-highlighting
)

bindkey -M viins jj vi-cmd-mode
export VI_MODE_SET_CURSOR=true
# oh-my-zsh end

# aliases
alias cls=clear
alias sl="exa --group-directories-first --icons --time-style=long-iso -la"
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
__conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
  else
    export PATH="$HOME/miniconda3/bin:$PATH"
  fi
fi
unset __conda_setup
# miniconda end

source $ZSH/oh-my-zsh.sh
