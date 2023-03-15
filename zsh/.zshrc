# Variables
export EDITOR=nvim
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:~/.local/share/bob/nvim-bin
source "$HOME/.cargo/env"
export PATH=$PATH:$HOME/.local/share/bob/nvim-bin
export PATH=$PATH:$HOME/.cargo/bin
export NVIM_DATA=$HOME/.local/share/nvim
export EDITOR=nvim

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

    export FLYCTL_INSTALL="/home/joogie/.fly"
    export PATH="$FLYCTL_INSTALL/bin:$PATH"
  ;;
  Darwin)
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"
    [ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"

    export PYTHON_PATH=$HOME/Library/Python/3.9/bin
    export PATH=$PATH:$PYTHON_PATH
    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/platform-tools
    export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
    export PATH=$PATH:$(pyenv root)/shims
    export PATH="`yarn global bin`:$PATH"

    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    export CONDA_AUTO_ACTIVATE_BASE=false
    __conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
            . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
        else
            export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<

    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C /opt/homebrew/bin/terraform terraform
  ;;
esac

# Plugins

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_TMUX_AUTOSTART=true
ZSH_THEME="powerlevel10k/powerlevel10k"
CASE_SENSITIVE="false"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

plugins=(
	git
	tmux
	z
	vi-mode
  direnv
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

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# pnpm
export PNPM_HOME="/home/joogie/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "`fnm env`"
# fnm end
