if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source $HOME/zsh-snap/znap.zsh
source $HOME/.cargo/env

znap source romkatv/powerlevel10k

export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="powerlevel10k/powerlevel10k"
# ZSH_TMUX_AUTOSTART=true
CASE_SENSITIVE="false"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

plugins=(
	git
	tmux
	z
	zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# Configurations
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"

# Aliases
alias cls=clear
alias so=source
alias open=wslview
alias tmux="TERM=screen-256color-bce tmux"

# Functions
work() { cd "/mnt/c/Users/prince.juguilon/Documents/Work/" }

# Variables
NVIM_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# bun completions
[ -s "/home/joogie/.bun/_bun" ] && source "/home/joogie/.bun/_bun"

# Bun
export BUN_INSTALL="/home/joogie/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
