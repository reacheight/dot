$dotfiles = $PSScriptRoot

function New-Link($path, $target) {
  if (-not (Test-Path $target)) { Write-Error "Missing target: $target"; return }
  $parent = Split-Path $path
  if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  New-Item -ItemType SymbolicLink -Force -Path $path -Target $target | Out-Null
  Write-Host "Linked: $path" -ForegroundColor Green
}

New-Link "$HOME\OneDrive\Документы\PowerShell\Microsoft.PowerShell_profile.ps1" `
         "$dotfiles\powershell\Microsoft.PowerShell_profile.ps1"

New-Link "$HOME\OneDrive\Документы\PowerShell\aliens.omp.json" `
         "$dotfiles\powershell\aliens.omp.json"

New-Link "$env:LOCALAPPDATA\nvim" "$dotfiles\nvim"

New-Link "$HOME\.wezterm.lua"          "$dotfiles\wezterm\wezterm.lua"
New-Link "$HOME\tokyonight_moon.toml"  "$dotfiles\wezterm\tokyonight_moon.toml"

New-Link "$env:LOCALAPPDATA\lazygit\config.yml" "$dotfiles\lazygit\config.yml"
New-Link "$env:LOCALAPPDATA\lazygit\pager.ps1" "$dotfiles\lazygit\pager.ps1"