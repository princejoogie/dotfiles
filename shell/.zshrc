# oh-my-zsh
export DISABLE_AUTO_UPDATE="true"

export ZSH="$HOME/.oh-my-zsh"

plugins=(
  z
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
alias wt=". _wt"
alias claude="claude --dangerously-skip-permissions"
alias om="opencode2 mini"
alias nd='nvim -u "$HOME/.config/nvim/diffview.lua" +DiffviewOpen "+tabclose 1"'

ask() {
  opencode2 run --model "xai/grok-4.6#low" "$*"
}

alias ask="noglob ask"

claudex() {
  ANTHROPIC_BASE_URL="http://127.0.0.1:8317" \
  ANTHROPIC_AUTH_TOKEN="sk-dummy" \
  ANTHROPIC_MODEL="gpt-5.6-sol" \
  ANTHROPIC_SMALL_FAST_MODEL="gpt-5.6-sol" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="gpt-5.6-sol" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="gpt-5.6-sol" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="gpt-5.6-sol" \
  CLAUDE_CODE_SUBAGENT_MODEL="gpt-5.6-sol" \
  CLAUDE_CODE_ALWAYS_ENABLE_EFFORT=1 \
  CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY=3 \
  ENABLE_TOOL_SEARCH=false \
  command claude --dangerously-skip-permissions --model "gpt-5.6-sol" "$@"
}

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
export PATH=$PATH:$HOME/.opencode/bin
export PATH=$PATH:$HOME/.lmstudio/bin
export PATH=$PATH:$HOME/.maestro/bin
export PATH=$PATH:$HOME/.grok/bin
export PATH=$PATH:$HOME/go/bin

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

# bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# bun end

source $ZSH/oh-my-zsh.sh
