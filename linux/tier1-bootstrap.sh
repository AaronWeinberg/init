#!/usr/bin/env bash
#cloud-config
# Tier 1 Bootstrap: minimal, platform-agnostic system setup

set -euo pipefail

### CONFIG ####################################################################
SHARED_GIT_URL="https://example.com/git"

### LOGGING ###################################################################
log() {
  echo "[bootstrap] $*"
}

### PACKAGE MANAGEMENT ########################################################
pkg_install() {
  local pkgs=("$@")

  sudo apt-get update -y
  sudo apt-get install -y "${pkgs[@]}"
}

### DOTFILES ##################################################################
install_dotfiles() {
  log "Installing dotfiles"

  wget -q -O "$HOME/.bashrc"    "$SHARED_GIT_URL/.bashrc"
  wget -q -O "$HOME/.gitconfig" "$SHARED_GIT_URL/.gitconfig"
}

### NVM #######################################################################
install_nvm() {
  if [[ -d "$HOME/.nvm" ]]; then
    log "NVM already installed"
    return
  fi

  log "Installing NVM"
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
}

### NODE ######################################################################
install_node() {
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

  log "Installing Node.js (LTS)"
  nvm install --lts
  nvm use --lts
}

### NPM GLOBALS ###############################################################
install_npm_globals() {
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

  log "Installing npm global packages"
  npm install -g \
    eslint \
    eslint-config-prettier \
    pnpm \
    prettier \
    typescript
}

### MAIN ######################################################################
main() {
  log "Starting Tier-1 bootstrap"

  pkg_install curl wget git ufw
  install_dotfiles
  install_nvm
  install_node
  install_npm_globals

  log "Bootstrap complete"
}

main "$@"
