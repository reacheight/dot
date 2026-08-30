$dotfiles = $PSScriptRoot

function New-Link($path, $target) {
  if (-not (Test-Path $target)) { Write-Error "Missing target: $target"; return }
  $parent = Split-Path $path
  if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  New-Item -ItemType SymbolicLink -Force -Path $path -Target $target | Out-Null
  Write-Host "Linked: $path" -ForegroundColor Green
}

New-Link "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" `
         "$dotfiles\powershell\Microsoft.PowerShell_profile.ps1"

New-Link "$HOME\Documents\PowerShell\aliens.omp.json" `
         "$dotfiles\powershell\aliens.omp.json"

New-Link "$env:LOCALAPPDATA\nvim" "$dotfiles\nvim"

New-Link "$HOME\.wezterm.lua"          "$dotfiles\wezterm\wezterm.lua"
New-Link "$HOME\tokyonight_moon.toml"  "$dotfiles\wezterm\tokyonight_moon.toml"

New-Link "$env:LOCALAPPDATA\lazygit\config.yml" "$dotfiles\lazygit\config.yml"

# todo:
# git
# git config name and email
# lazygit
# wezterm
# powershell 7
# neovim
# fonts (maple, jetbrains mono, nerds)
# yazi and deps
# winlibs.com
# oh-my-posh
# fnm