# Variables
export EDITOR=nvim
export PATH=$PATH:/usr/local/go/bin
source "$HOME/.cargo/env"
export PATH=$PATH:$HOME/.cargo/bin

case `uname` in
  Linux)
    export NVM_DIR="$HOME/.config/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
    export PATH=$PATH:$JAVA_HOME/bin

    export ANDROID_HOME=$HOME/Android/Sdk
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/platform-tools
    export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
  ;;
  Darwin)
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"
    [ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"

    export PYTHON_PAT=$HOME/Library/Python/3.9/bin
    export PATH=$PATH:$PYTHON_PATH

    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/platform-tools
    export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
  ;;
esac

# Plugins

source $HOME/Documents/github/znap/zsh-snap/znap.zsh
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

znap source romkatv/powerlevel10k
znap source zsh-users/zsh-autosuggestions

export ZSH="$HOME/.oh-my-zsh"

ZSH_TMUX_AUTOSTART=true
CASE_SENSITIVE="false"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

plugins=(
	git
	tmux
	z
	vi-mode
)

source $ZSH/oh-my-zsh.sh

# Configurations
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"

# Aliases
alias cls=clear
alias so=source
alias x=exit
alias e=echo
alias cl="xclip -selection c"
alias ipv4="echo $(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}')"

# Variables
NVIM_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# direnv
eval "$(direnv hook zsh)"
