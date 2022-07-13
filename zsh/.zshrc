source ~/codes/github/zsh-snap/znap.zsh
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source $HOME/codes/github/zsh-snap/znap.zsh
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
pqs() { sudo service postgresql start }
pqc() { sudo service postgresql stop }
pqr() { sudo service postgresql restart }
lsix() { montage -tile 7x1 -label %f -background black -fill white "$@" gif:- | convert - -colors 16 sixel:-; }

# Variables
NVIM_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
