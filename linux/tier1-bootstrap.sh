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

PRIMARY_USER="aaron"
SSH_AUTH_KEYS_URL="$SHARED_SSH_URL/id_ed25519.pub"

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

### MODE VALIDATION ###########################################################
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

  local pkgs=(
    ca-certificates
    curl
    dos2unix
    git
    htop
    wget

    # Python (system tooling)
    python3
    python3-pip
    python3-venv
  )

  # Desktop + WSL (human-facing systems)
  if [[ "$MODE_VPS" == false ]]; then
    pkgs+=(xclip)
  fi

  # Desktop-only UX packages
  if [[ "$MODE_DESKTOP" == true ]]; then
    pkgs+=(fonts-firacode)
  fi

  pkg_install "${pkgs[@]}"
}

### LOCALE ####################################################################
configure_locale() {
  log "Configuring system locale"

  sudo apt-get install -y locales

  sudo sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
  sudo locale-gen

  sudo update-locale LANG=en_US.UTF-8
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

### CLOUD USER DETECTION #######################################################
detect_default_cloud_user() {
  local candidates=(
    debian
    ubuntu
    ec2-user
    rocky
    almalinux
    oracle
    centos
    admin
  )

  for user in "${candidates[@]}"; do
    if id "$user" &>/dev/null && [[ "$user" != "$PRIMARY_USER" ]]; then
      echo "$user"
      return 0
    fi
  done

  return 1
}

### USER MANAGEMENT ###########################################################
ensure_primary_user() {
  if id "$PRIMARY_USER" &>/dev/null; then
    log "Primary user '$PRIMARY_USER' already exists"
    return
  fi

  log "Creating primary user '$PRIMARY_USER'"

  sudo adduser --disabled-password --gecos "" "$PRIMARY_USER"
  sudo usermod -aG sudo "$PRIMARY_USER"

  sudo install -d -m 700 "/home/$PRIMARY_USER/.ssh"
  sudo curl -fsSL "$SSH_AUTH_KEYS_URL" \
    -o "/home/$PRIMARY_USER/.ssh/authorized_keys"

  sudo chown -R "$PRIMARY_USER:$PRIMARY_USER" "/home/$PRIMARY_USER/.ssh"
  sudo chmod 600 "/home/$PRIMARY_USER/.ssh/authorized_keys"
}

disable_cloud_init_user_management() {
  if [[ ! -d /etc/cloud/cloud.cfg.d ]]; then
    return
  fi

  log "Disabling cloud-init user management"

  sudo tee /etc/cloud/cloud.cfg.d/99-disable-user-management.cfg >/dev/null <<EOF
users: []
disable_root: true
preserve_hostname: true
EOF
}

schedule_default_user_removal() {
  if systemctl is-enabled remove-default-user.service &>/dev/null; then
    log "Default user removal already scheduled"
    return
  fi

  local user
  user="$(detect_default_cloud_user || true)"

  if [[ -z "$user" ]]; then
    log "No default cloud user detected"
    return
  fi

  log "Scheduling removal of '$user' on next boot"

  sudo tee /etc/systemd/system/remove-default-user.service >/dev/null <<EOF
[Unit]
Description=Remove default cloud user
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/deluser --remove-home $user
ExecStartPost=/bin/rm -f /etc/systemd/system/remove-default-user.service
ExecStartPost=/bin/systemctl daemon-reload

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable remove-default-user.service
}

### DOTFILES ##################################################################
install_linux_dotfiles() {
  log "Installing Linux dotfiles"

  # Ensure ownership (cloud-init safety)
  sudo chown -R "$(id -un):$(id -gn)" "$HOME"

  wget -q -O "$HOME/.bashrc"        "$LINUX_DOTFILES_URL/.bashrc"
  wget -q -O "$HOME/.bash_aliases" "$LINUX_DOTFILES_URL/.bash_aliases"
  wget -q -O "$HOME/.inputrc"      "$LINUX_DOTFILES_URL/.inputrc"
}

### GIT CONFIG ################################################################
install_git_config() {
  log "Installing Git configuration"
  wget -q -O "$HOME/.gitconfig"        "$SHARED_GIT_URL/.gitconfig"
  wget -q -O "$HOME/.gitignore_global" "$SHARED_GIT_URL/.gitignore_global"
}

### SSH CLIENT / IDENTITY #####################################################
install_ssh_client() {
  log "Setting up SSH client"

  local ssh_dir="$HOME/.ssh"
  local pubkey="$ssh_dir/id_ed25519.pub"

  mkdir -p "$ssh_dir"
  chmod 700 "$ssh_dir"

  # Only install public key on Desktop + WSL
  if [[ "$MODE_DESKTOP" == true || "$MODE_WSL" == true ]]; then
    log "Installing SSH public key"
    wget -q -O "$pubkey" "$SHARED_SSH_URL/id_ed25519.pub"
    chmod 644 "$pubkey"
    chown "$USER:$USER" "$pubkey"
  else
    log "Skipping SSH public key install (VPS mode)"
  fi
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
  
  if [[ "$MODE_VPS" == true ]]; then
    ensure_primary_user
    disable_cloud_init_user_management
    schedule_default_user_removal
  fi

  configure_locale
  set_hostname
  install_linux_dotfiles
  install_git_config
  install_ssh_client
  install_helix_config

  if [[ "$MODE_WSL" == true ]]; then
    log "Mode: WSL — skipping Node.js toolchain"
    log "Bootstrap complete (WSL)"
    return
  fi

  # Desktop + VPS
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
