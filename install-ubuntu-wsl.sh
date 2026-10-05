#!/usr/bin/env bash
# Ubuntu on WSL bootstrap for this dotfiles repo.
#
# Usage (as your user, needs working sudo):
#   ./install-ubuntu-wsl.sh
# Fresh WSL accounts have no password, so sudo does not work yet:
#   wsl -u root -d Ubuntu          # then: passwd <your-user>
# and re-run the script as your user.
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

log() { printf '%s==>%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s==>%s %s\n' "$YELLOW" "$RESET" "$*"; }
die() {
  printf '%serror:%s %s\n' "$RED" "$RESET" "$*" >&2
  exit 1
}

run_root() {
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

case $(uname -m) in
x86_64)
  MUSL_ARCH="x86_64-unknown-linux-musl"
  LAZYGIT_ARCH="x86_64"
  NVIM_ARCH="x86_64"
  DEB_ARCH="amd64"
  ;;
aarch64)
  MUSL_ARCH="aarch64-unknown-linux-musl"
  LAZYGIT_ARCH="arm64"
  NVIM_ARCH="aarch64"
  DEB_ARCH="arm64"
  ;;
*) die "Unsupported architecture: $(uname -m)" ;;
esac

require_ubuntu() {
  local id
  id=$(. /etc/os-release 2>/dev/null && printf '%s' "${ID:-}")
  [[ $id == ubuntu ]] || die "This script targets Ubuntu (found: ${id:-unknown})."
  if ! uname -r | grep -qi microsoft; then
    warn "Kernel string has no 'microsoft' - not on WSL? Continuing anyway."
  fi
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    die "Run as your user, not root (config symlinks must land in your HOME)."
  fi
  if ! sudo -v 2>/dev/null; then
    die "sudo is not available. On a fresh WSL account there is no password
yet, so: run 'wsl -u root -d Ubuntu', run 'passwd <your-user>' to set one,
then re-run this script as your user."
  fi
}

# Resolve the browser_download_url of the latest-release asset whose
# filename ends with $2 (e.g. "x86_64-unknown-linux-musl.tar.gz").
gh_asset_url() {
  local repo=$1 sub=$2 json
  json=$(curl -fsSL --retry 3 --max-time 60 "https://api.github.com/repos/$repo/releases/latest") ||
    return 1
  printf '%s\n' "$json" |
    sed -nE 's/.*"browser_download_url": *"([^"]*'"$sub"')".*/\1/p' |
    sed -n 1p
}

fetch() { # url dest
  curl -fL --retry 3 --max-time 300 -o "$2" "$1"
}

# Download a release tarball, pull one binary out, install to ~/.local/bin.
install_single_bin() { # label repo filename-suffix binary
  local label=$1 repo=$2 sub=$3 bin=$4
  local url tmp binpath
  url=$(gh_asset_url "$repo" "$sub") || die "Could not resolve $label release ($repo)"
  [[ -n $url ]] || die "Could not resolve $label release asset ($repo, $sub)"
  log "Installing $label from $url"
  tmp=$(mktemp -d)
  fetch "$url" "$tmp/pkg.tar.gz"
  tar -xzf "$tmp/pkg.tar.gz" -C "$tmp"
  binpath=$(find "$tmp" -type f -name "$bin" | sed -n 1p)
  [[ -n $binpath ]] || die "$bin not found in $label release"
  install -Dm755 "$binpath" "$HOME/.local/bin/$bin"
  rm -rf "$tmp"
}

configure_git() {
  log "Setting git user.name, user.email, and delta pager"
  git config --global user.name "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
  git config --global core.pager delta
  git config --global interactive.diffFilter "delta --color-only"
  git config --global delta.navigate true
}

add_yazi_repo() {
  if [[ -f /etc/apt/sources.list.d/yazi.list ]]; then
    log "yazi apt repo already configured"
    return 0
  fi
  log "Adding official yazi apt repo (yazi-rs.github.io/builds)"
  run_root bash -c 'curl -fsSL --retry 3 https://yazi-rs.github.io/builds/yazi-keyring.gpg -o /usr/share/keyrings/yazi-keyring.gpg'
  printf 'deb [signed-by=/usr/share/keyrings/yazi-keyring.gpg] https://yazi-rs.github.io/builds/ stable main\n' |
    run_root tee /etc/apt/sources.list.d/yazi.list >/dev/null
}

install_packages() {
  log "Installing apt packages (fish, jq, fzf, zoxide, yazi, 7zip, ffmpeg, ...)"
  export DEBIAN_FRONTEND=noninteractive
  add_yazi_repo
  run_root apt-get update
  run_root apt-get install -y --no-install-recommends \
    fish jq poppler-utils fzf 7zip ffmpeg fontconfig unzip curl git \
    fonts-jetbrains-mono zoxide yazi
  # Only useful under WSLg; do not fail the whole install over it.
  run_root apt-get install -y wl-clipboard 2>/dev/null ||
    warn "wl-clipboard not installed (optional, needs WSLg)"
}

install_nvim() {
  local url tmp
  url=$(gh_asset_url neovim/neovim "nvim-linux-${NVIM_ARCH}.tar.gz") ||
    die "Could not resolve neovim release"
  log "Installing Neovim from $url"
  tmp=$(mktemp -d)
  fetch "$url" "$tmp/nvim.tar.gz"
  tar -xzf "$tmp/nvim.tar.gz" -C "$tmp"
  run_root rm -rf "/opt/nvim-linux-${NVIM_ARCH}"
  run_root mv "$tmp/nvim-linux-${NVIM_ARCH}" "/opt/nvim-linux-${NVIM_ARCH}"
  run_root ln -sf "/opt/nvim-linux-${NVIM_ARCH}/bin/nvim" /usr/local/bin/nvim
  rm -rf "$tmp"
}

# Install the official ripgrep .deb from the latest release (e.g.
# ripgrep_15.2.0-1_amd64.deb); apt resolves its dependencies.
install_ripgrep() {
  local url tmp
  url=$(gh_asset_url BurntSushi/ripgrep "${DEB_ARCH}.deb") ||
    die "Could not resolve ripgrep .deb release"
  [[ -n $url ]] || die "Could not resolve ripgrep .deb asset (${DEB_ARCH})"
  log "Installing ripgrep from $url"
  tmp=$(mktemp -d)
  fetch "$url" "$tmp/ripgrep.deb"
  run_root apt-get install -y "$tmp/ripgrep.deb"
  rm -rf "$tmp"
  # Safety net in case the package does not ship the rg symlink.
  command -v rg >/dev/null || run_root ln -sf /usr/bin/ripgrep /usr/bin/rg
}

install_github_tools() {
  install_single_bin "fd" sharkdp/fd "$MUSL_ARCH.tar.gz" fd
  install_ripgrep
  install_single_bin "git-delta" dandavison/delta "$MUSL_ARCH.tar.gz" delta
  install_single_bin "lazygit" jesseduffield/lazygit "linux_${LAZYGIT_ARCH}.tar.gz" lazygit
}

install_maple_nf() {
  local dest="$HOME/.local/share/fonts/maple-mono-nf"
  local url="https://github.com/subframe7536/maple-font/releases/latest/download/MapleMono-NF.zip"

  if fc-list 2>/dev/null | grep -qi "Maple Mono NF"; then
    log "Maple Mono NF already installed"
    return 0
  fi

  log "Installing Maple Mono NF"
  local tmp
  tmp=$(mktemp -d)
  if ! curl -fL --retry 3 -o "$tmp/MapleMono-NF.zip" "$url"; then
    rm -rf "$tmp"
    warn "Maple Mono NF download failed; skipping (cosmetic only)."
    return 0
  fi
  mkdir -p "$dest"
  unzip -oq "$tmp/MapleMono-NF.zip" -d "$dest"
  rm -rf "$tmp"
  fc-cache -f "$HOME/.local/share/fonts" || true
}

set_login_shell_fish() {
  local fish_path
  fish_path=$(command -v fish) || die "fish not found"
  local current
  current=$(getent passwd "$(id -un)" | cut -d: -f7)
  if [[ "$current" == "$fish_path" ]]; then
    log "Login shell already fish"
    return 0
  fi
  if [[ -f /etc/shells ]] && ! grep -qx "$fish_path" /etc/shells; then
    log "Adding $fish_path to /etc/shells"
    printf '%s\n' "$fish_path" | run_root tee -a /etc/shells >/dev/null
  fi
  log "Setting login shell to fish (takes effect on next login)"
  run_root usermod --shell "$fish_path" "$(id -un)"
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

link_configs() {
  log "Linking nvim, lazygit, fish, and yazi configs"
  link "$HOME/.config/nvim" "$DOTFILES/nvim"
  link "$HOME/.config/lazygit" "$DOTFILES/lazygit"
  # Link only config.fish so fish can still write fish_variables locally.
  link "$HOME/.config/fish/config.fish" "$DOTFILES/fish/config.fish"
  link "$HOME/.config/yazi" "$DOTFILES/yazi"
}

verify_commands() {
  local cmd
  local path="$HOME/.local/bin:/usr/local/bin:$PATH"
  for cmd in nvim fish lazygit yazi delta jq fd rg fzf zoxide ffmpeg pdftotext 7z; do
    PATH="$path" command -v "$cmd" >/dev/null || die "$cmd is not on PATH after install"
  done
}

main() {
  require_ubuntu
  configure_git
  install_packages
  install_nvim
  install_github_tools
  install_maple_nf
  set_login_shell_fish
  link_configs
  verify_commands
  log "Done. Re-login for the fish shell; ~/.local/bin is on PATH in bash and fish."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
