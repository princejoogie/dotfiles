Set-PoshPrompt -Theme C:\Users\prince.juguilon\.joogie.omp.json

# Variables
$NVIM_CONFIG_PATH = "C:\Users\prince.juguilon\AppData\Local\nvim"
$SSH_AGENT_PATH = "C:\Program Files\Git\cmd\start-ssh-agent.cmd"

# Functions
function fdir { fd -0 --type d | fzf --read0 }
function Show-GitLog { git log --graph --decorate --oneline }
function which ($command) {
  Get-Command -name $command -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
function vimrc {
  Set-Location -Path $NVIM_CONFIG_PATH
}

# Aliases
Set-Alias -Name gitlog -Value Show-GitLog
Set-Alias ssa $SSH_AGENT_PATH

Remove-Alias diff -Force
Remove-Alias rm
Remove-Alias cp
Remove-Alias mv
Remove-Alias kill

# Configs
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode vi
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -ViModeIndicator Cursor

# Terminal Icons
Import-Module -Name Terminal-Icons

# Fzf
Import-Module -Name PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl-f' -PSReadlineChordReverseHistory 'Ctrl-r'
