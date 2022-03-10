if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source $HOME/zsh-snap/znap.zsh
source $HOME/.cargo/env

znap source romkatv/powerlevel10k

export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="powerlevel10k/powerlevel10k"
CASE_SENSITIVE="false"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

plugins=(
	git
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

# Functions
pat() { echo "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" }
work() { cd "/mnt/c/Users/prince.juguilon/Documents/Work/" }

# Variables
NVIM_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
APP_PW_BITBUCKET="SH3uh5cwLkkhHqQ8LSa7"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

PATH="/home/joogie/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/joogie/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/joogie/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/joogie/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/joogie/perl5"; export PERL_MM_OPT;
