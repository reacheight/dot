#!/usr/bin/env bash
# Fedora Workstation bootstrap for this dotfiles repo.
set -euo pipefail

DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

GIT_NAME="Roman Mendaliev"
GIT_EMAIL="reacheight8@gmail.com"

if [[ -t 1 ]]; then
  GREEN=$'\033[32m'
  YELLOW=$'\033[33m'
  RED=$'\033[31m'
  RESET=$'\033[0m'
else
  GREEN= YELLOW= RED= RESET=
fi

log()  { printf '%s==>%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s==>%s %s\n' "$YELLOW" "$RESET" "$*"; }
die()  { printf '%serror:%s %s\n' "$RED" "$RESET" "$*" >&2; exit 1; }

run_root() {
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

require_fedora() {
  if [[ ! -f /etc/fedora-release ]]; then
    die "This script targets Fedora Workstation (dnf)."
  fi
}

ensure_copr_plugin() {
  if dnf copr --help >/dev/null 2>&1; then
    return 0
  fi
  log "Installing dnf copr plugin"
  run_root dnf install -y dnf5-plugins || run_root dnf install -y dnf-plugins-core
}

enable_copr() {
  local name=$1
  if dnf copr list 2>/dev/null | grep -q "$name"; then
    return 0
  fi
  log "Enabling COPR $name"
  run_root dnf -y copr enable "$name"
}

link() {
  local path=$1
  local target=$2

  if [[ ! -e "$target" ]]; then
    die "Missing target: $target"
  fi

  mkdir -p "$(dirname "$path")"

  if [[ -L "$path" ]]; then
    local current
    current=$(readlink "$path")
    if [[ "$current" == "$target" ]]; then
      log "Already linked: $path"
      return 0
    fi
  fi

  if [[ -e "$path" || -L "$path" ]]; then
    local bak="${path}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$path" "$bak"
    warn "Backed up: $path -> $bak"
  fi

  ln -s "$target" "$path"
  log "Linked: $path -> $target"
}

configure_git() {
  log "Setting git user.name and user.email"
  git config --global user.name "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
}

install_packages() {
  ensure_copr_plugin

  # Ghostty is COPR-only on Fedora. lazygit and yazi are not always in the
  # official repos, so enable their COPRs before the install transaction.
  enable_copr scottames/ghostty
  enable_copr atim/lazygit
  enable_copr lihaohong/yazi

  log "Installing nvim, ghostty, fish, lazygit, yazi, JetBrains Mono"
  run_root dnf install -y neovim ghostty fish lazygit yazi jetbrains-mono-fonts unzip curl fontconfig

  local cmd
  for cmd in nvim ghostty fish lazygit yazi; do
    command -v "$cmd" >/dev/null || die "$cmd is not on PATH after install"
  done
}

install_maple() {
  local dest="$HOME/.local/share/fonts/maple-mono"
  local url="https://github.com/subframe7536/maple-font/releases/latest/download/MapleMono-TTF.zip"

  if fc-list 2>/dev/null | grep -qi "Maple Mono"; then
    log "Maple Mono already installed"
    return 0
  fi

  log "Installing Maple Mono"
  local tmp
  tmp=$(mktemp -d)
  curl -fL --retry 3 -o "$tmp/MapleMono-TTF.zip" "$url"
  mkdir -p "$dest"
  unzip -oq "$tmp/MapleMono-TTF.zip" -d "$dest"
  rm -rf "$tmp"
  fc-cache -f "$HOME/.local/share/fonts"
}

link_configs() {
  log "Linking nvim and lazygit configs"
  link "$HOME/.config/nvim" "$DOTFILES/nvim"
  link "$HOME/.config/lazygit" "$DOTFILES/lazygit"
}

main() {
  require_fedora
  configure_git
  install_packages
  install_maple
  link_configs
  log "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
