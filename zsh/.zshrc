if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source $HOME/zsh-snap/znap.zsh
source $HOME/.cargo/env

znap source romkatv/powerlevel10k

export ZSH="$HOME/.oh-my-zsh"
# export TERM=xterm-256color

# ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_TMUX_AUTOSTART=true
CASE_SENSITIVE="false"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

plugins=(
	git
	tmux
	z
	zsh-autosuggestions
	vi-mode
)

source $ZSH/oh-my-zsh.sh

# Configurations
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"

if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
  alias nvim=nvr -cc split --remote-wait +'set bufhidden=wipe'
fi

if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
  export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
  export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
else
  export VISUAL="nvim"
  export EDITOR="nvim"
fi

# Aliases
alias cls=clear
alias so=source
alias open=wslview
alias tmux="TERM=screen-256color-bce tmux"

# Functions
work() { cd "/mnt/c/Users/prince.juguilon/Documents/Work/" }
pqs() { sudo service postgresql start }
pqc() { sudo service postgresql stop }
pqr() { sudo service postgresql restart }
lsix() { montage -tile 7x1 -label %f -background black -fill white "$@" gif:- | convert - -colors 16 sixel:-; }

# Variables
NVIM_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# go
export PATH=$PATH:/usr/local/go/bin

# bun completions
[ -s "/home/joogie/.bun/_bun" ] && source "/home/joogie/.bun/_bun"

# Bun
export BUN_INSTALL="/home/joogie/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Fly.io
export FLYCTL_INSTALL="/home/joogie/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"
