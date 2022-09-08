oh-my-posh init pwsh --config "~\\Documents\\PowerShell\\.joogie.omp.json" | Invoke-Expression

function which ($command) {
  Get-Command -name $command -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

Remove-Alias rm
Remove-Alias cp
Remove-Alias mv
Remove-Alias kill

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -EditMode vi
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -ViModeIndicator Cursor
