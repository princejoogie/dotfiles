# oh-my-zsh
autoload -U compinit
compinit

export DISABLE_AUTO_UPDATE="true"

export ZSH="$HOME/.oh-my-zsh"

plugins=(
  z
  gh
  aws
  fnm
  git
  tmux
  docker
  vi-mode
  zsh-autosuggestions
  zsh-syntax-highlighting
  fast-syntax-highlighting
)

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

# aliases
alias cls=clear
alias sl="exa --group-directories-first --icons --time-style=long-iso -la"
alias so=source
alias x=exit
alias G=git
alias t=tmux
alias lta="ls -lta --human-readable"
# alises end

# variables
export EDITOR=nvim
export MANPAGER='nvim +Man!'
export PATH=$PATH:/opt/homebrew/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.local/share/fnm
export PATH=$PATH:$HOME/.local/custom/bin
export PATH=$PATH:$HOME/.local/share/bob/nvim-bin
export PATH=$PATH:$HOME/.duckdb/cli/latest
export PATH=$PATH:$HOME/.lmstudio/bin

if [[ -f "$HOME/.private.sh" ]]; then
  source "$HOME/.private.sh"
fi
# variables end

# starship
if [[ -x "$(command -v starship)" ]]; then
  eval "$(starship init zsh)"
fi
# starship end

# fnm
if [[ -x "$(command -v fnm)" ]]; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi
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

source $ZSH/oh-my-zsh.sh
