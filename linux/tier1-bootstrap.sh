#!/usr/bin/env bash
#cloud-config
# Tier 1 – Bootstrap
# Minimal, role-aware, platform-agnostic user setup

set -euo pipefail

### CONFIG ####################################################################
BASE_URL="https://raw.githubusercontent.com/AaronWeinberg/init/master"

SHARED_URL="$BASE_URL/shared"
LINUX_DOTFILES_URL="$BASE_URL/linux/dotfiles"

SHARED_GIT_URL="$SHARED_URL/git"
SHARED_SSH_URL="$SHARED_URL/ssh"
SHARED_HELIX_URL="$SHARED_URL/helix"

### LOGGING ###################################################################
log() {
  echo "[bootstrap] $*"
}

### MODE FLAGS ###############################################################
MODE_DESKTOP=false
MODE_VPS=false
MODE_WSL=false
DESIRED_HOSTNAME=""

usage() {
  cat <<EOF
Usage: $0 [--desktop | --vps | --wsl]

  --desktop   Workstation bootstrap
  --vps       Server / VPS bootstrap
  --wsl       WSL bootstrap

Exactly one mode must be specified.
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --desktop) MODE_DESKTOP=true ;;
    --vps)     MODE_VPS=true ;;
    --wsl)     MODE_WSL=true ;;
    -h|--help) usage ;;
    *) echo "Unknown argument: $1"; usage ;;
  esac
  shift
done

### MODE VALIDATION (set -e SAFE) #############################################
mode_count=0

if [[ "$MODE_DESKTOP" == true ]]; then
  ((mode_count+=1))
  DESIRED_HOSTNAME="desktop"
fi

if [[ "$MODE_VPS" == true ]]; then
  ((mode_count+=1))
  DESIRED_HOSTNAME="vps"
fi

if [[ "$MODE_WSL" == true ]]; then
  ((mode_count+=1))
  DESIRED_HOSTNAME="wsl"
fi

if [[ "$mode_count" -ne 1 ]]; then
  usage
fi

### PACKAGE MANAGEMENT ########################################################
pkg_install() {
  sudo apt-get update -y
  sudo apt-get install -y "$@"
}

### BASE PACKAGES #############################################################
install_base_packages() {
  log "Installing base packages"
  pkg_install curl wget git ca-certificates
}

### HOSTNAME ##################################################################
set_hostname() {
  local current
  current="$(hostname)"

  if [[ "$current" == "$DESIRED_HOSTNAME" ]]; then
    log "Hostname already set to '$current'"
    return
  fi

  log "Setting hostname to '$DESIRED_HOSTNAME'"
  sudo hostnamectl set-hostname "$DESIRED_HOSTNAME"
}

### DOTFILES ##################################################################
install_linux_dotfiles() {
  log "Installing Linux dotfiles"

  # Ensure ownership (cloud-init safety)
  sudo chown -R "$USER:$USER" "$HOME"

  wget -q -O "$HOME/.bashrc"   "$LINUX_DOTFILES_URL/.bashrc"
  wget -q -O "$HOME/.inputrc" "$LINUX_DOTFILES_URL/.inputrc"
}

### GIT CONFIG ################################################################
install_git_config() {
  log "Installing Git configuration"
  wget -q -O "$HOME/.gitconfig"        "$SHARED_GIT_URL/.gitconfig"
  wget -q -O "$HOME/.gitignore_global" "$SHARED_GIT_URL/.gitignore_global"
}

### SSH CLIENT CONFIG #########################################################
install_ssh_config() {
  log "Installing SSH client configuration"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
}

### HELIX CONFIG ##############################################################
install_helix_config() {
  log "Installing Helix configuration"
  mkdir -p "$HOME/.config/helix"
  wget -q -O "$HOME/.config/helix/config.toml" \
    "$SHARED_HELIX_URL/config.toml"
  wget -q -O "$HOME/.config/helix/languages.toml" \
    "$SHARED_HELIX_URL/languages.toml"
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

  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    log "ERROR: nvm.sh not found"
    return 1
  fi

  log "Installing Node.js (LTS)"

  # nvm is NOT nounset-safe (source + commands)
  set +u
  # shellcheck source=/dev/null
  source "$NVM_DIR/nvm.sh"

  nvm install --lts
  nvm use --lts --delete-prefix

  set -u
}

### NPM GLOBALS ###############################################################
install_npm_globals() {
  export NVM_DIR="$HOME/.nvm"

  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    log "ERROR: nvm.sh not found"
    return 1
  fi

  log "Installing npm global packages"

  set +u
  # shellcheck source=/dev/null
  source "$NVM_DIR/nvm.sh"

  npm install -g \
    eslint \
    eslint-config-prettier \
    pnpm \
    prettier \
    typescript

  set -u
}

### MAIN ######################################################################
main() {
  log "Starting Tier-1 bootstrap"

  install_base_packages
  set_hostname
  install_linux_dotfiles
  install_git_config
  install_ssh_config
  install_helix_config

  if [[ "$MODE_WSL" == true ]]; then
    log "Mode: WSL — skipping Node.js toolchain"
    log "Bootstrap complete (WSL)"
    return
  fi

  # Desktop + VPS get Node tooling
  install_nvm
  install_node
  install_npm_globals

  if [[ "$MODE_VPS" == true ]]; then
    log "Bootstrap complete (VPS)"
    return
  fi

  if [[ "$MODE_DESKTOP" == true ]]; then
    log "Bootstrap complete (Desktop)"
    return
  fi
}

main "$@"
