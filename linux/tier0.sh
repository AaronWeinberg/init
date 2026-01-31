#!/usr/bin/env bash
#cloud-config
# Tier 0
# Minimal, role-aware, platform-agnostic user setup

set -euo pipefail

### CONFIG ####################################################################
BASE_URL="https://raw.githubusercontent.com/AaronWeinberg/init/master"

SHARED_URL="$BASE_URL/dotfiles/shared"
LINUX_DOTFILES_URL="$BASE_URL/dotfiles/linux"

SHARED_GIT_URL="$SHARED_URL/git"
SHARED_SSH_URL="$SHARED_URL/ssh"
SHARED_HELIX_URL="$SHARED_URL/helix"

PRIMARY_USER="aaron"
SSH_AUTH_KEYS_URL="$SHARED_SSH_URL/id_ed25519.pub"

DEFAULT_USER_REMOVAL_SCHEDULED=false

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

if [[ "$MODE_VPS" == true && "$(id -u)" -ne 0 ]]; then
  echo "ERROR: Tier 0 must be run as root in --vps mode"
  exit 1
fi

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
  apt-get update -y
  apt-get install -y "$@"
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
    python3
    python3-pip
    python3-venv
    build-essential
  )

  if [[ "$MODE_VPS" == false ]]; then
    pkgs+=(xclip)
  fi

  if [[ "$MODE_DESKTOP" == true ]]; then
    pkgs+=(fonts-firacode)
  fi

  pkg_install "${pkgs[@]}"
}

### LOCALE ####################################################################
configure_locale() {
  log "Configuring system locale"

  apt-get install -y locales

  sed -i \
    -e 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' \
    -e 's/^# *en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' \
    /etc/locale.gen

  locale-gen
  update-locale LANG=en_US.UTF-8
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
  hostnamectl set-hostname "$DESIRED_HOSTNAME"
}

### CLOUD USER DETECTION #######################################################
detect_default_cloud_user() {
  local candidates=(
    debian ubuntu ec2-user rocky almalinux oracle centos admin
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

  adduser --disabled-password --gecos "" "$PRIMARY_USER"
  usermod -aG sudo "$PRIMARY_USER"

  install -d -m 700 "/home/$PRIMARY_USER/.ssh"
  curl -fsSL "$SSH_AUTH_KEYS_URL" \
    -o "/home/$PRIMARY_USER/.ssh/authorized_keys"

  chown -R "$PRIMARY_USER:$PRIMARY_USER" "/home/$PRIMARY_USER/.ssh"
  chmod 600 "/home/$PRIMARY_USER/.ssh/authorized_keys"
}

disable_cloud_init_user_management() {
  [[ -d /etc/cloud/cloud.cfg.d ]] || return

  log "Disabling cloud-init user management"

  tee /etc/cloud/cloud.cfg.d/99-disable-user-management.cfg >/dev/null <<EOF
users: []
disable_root: true
preserve_hostname: true
EOF
}

schedule_default_user_removal() {
  if systemctl is-enabled remove-default-user.service &>/dev/null; then
    DEFAULT_USER_REMOVAL_SCHEDULED=true
    return
  fi

  local user
  user="$(detect_default_cloud_user || true)"

  if [[ -z "$user" ]]; then
    log "No default cloud user detected — reboot not required"
    return
  fi

  log "Scheduling removal of '$user' on next boot"

  tee /etc/systemd/system/remove-default-user.service >/dev/null <<EOF
[Unit]
Description=Remove default cloud user
After=multi-user.target cloud-init.service

[Service]
Type=oneshot
ExecStart=/usr/sbin/deluser --remove-home ${user}
ExecStartPost=/bin/rm -f /etc/systemd/system/remove-default-user.service
ExecStartPost=/bin/systemctl daemon-reload

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable remove-default-user.service

  DEFAULT_USER_REMOVAL_SCHEDULED=true
}

### USER CONTEXT EXECUTION ####################################################
run_as_primary_user() {
  sudo -u "$PRIMARY_USER" -H bash -lc "$1"
}

export -f run_as_primary_user

### DOTFILES ##################################################################
install_linux_dotfiles() {
  log "Installing Linux dotfiles"

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

### SSH CLIENT ################################################################
install_ssh_client() {
  log "Setting up SSH client"

  local ssh_dir="$HOME/.ssh"
  mkdir -p "$ssh_dir"
  chmod 700 "$ssh_dir"

  if [[ "$MODE_DESKTOP" == true || "$MODE_WSL" == true ]]; then
    wget -q -O "$ssh_dir/id_ed25519.pub" "$SHARED_SSH_URL/id_ed25519.pub"
    chmod 644 "$ssh_dir/id_ed25519.pub"
  fi
}

### HELIX #####################################################################
install_helix_config() {
  log "Installing Helix configuration"
  mkdir -p "$HOME/.config/helix"
  wget -q -O "$HOME/.config/helix/config.toml" \
    "$SHARED_HELIX_URL/config.toml"
  wget -q -O "$HOME/.config/helix/languages.toml" \
    "$SHARED_HELIX_URL/languages.toml"
}

### NODE TOOLCHAIN ############################################################
source_nvm() {
  set +u
  source "$NVM_DIR/nvm.sh"
  set -u
}

install_nvm() {
  [[ -d "$HOME/.nvm" ]] && return
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
}

install_node() {
  export NVM_DIR="$HOME/.nvm"
  source_nvm
  nvm install --lts
  nvm use --lts --delete-prefix
}

install_npm_globals() {
  export NVM_DIR="$HOME/.nvm"
  source_nvm
  npm install -g eslint eslint-config-prettier pnpm prettier typescript
}

### EXPORT USER-SCOPED FUNCTIONS ##############################################
export -f \
  install_linux_dotfiles \
  install_git_config \
  install_ssh_client \
  install_helix_config \
  install_nvm \
  install_node \
  install_npm_globals \
  source_nvm

### VPS REBOOT PROMPT ##########################################################
prompt_vps_reboot() {
  if [[ "$DEFAULT_USER_REMOVAL_SCHEDULED" != true ]]; then
    log "Tier-0 complete (VPS — no reboot required)"
    return
  fi

  echo
  echo "================================================="
  echo " Tier 0 complete (VPS)"
  echo
  echo " A reboot is required before running Tier 1:"
  echo "  - Completes user handoff"
  echo "  - Allows safe removal of the default cloud user"
  echo
  echo " Reboot now? [y/N]"
  echo "================================================="
  read -r answer

  case "$answer" in
    [yY]|[yY][eE][sS]) reboot ;;
    *) log "Reboot skipped — reboot manually before Tier 1" ;;
  esac
}

### MAIN ######################################################################
main() {
  log "Starting Tier-0"

  install_base_packages
  configure_locale

  if [[ "$MODE_VPS" == true ]]; then
    ensure_primary_user
    disable_cloud_init_user_management
    schedule_default_user_removal
  fi

  set_hostname

  if [[ "$MODE_VPS" == true ]]; then
    run_as_primary_user install_linux_dotfiles
    run_as_primary_user install_git_config
    run_as_primary_user install_ssh_client
    run_as_primary_user install_helix_config
  else
    install_linux_dotfiles
    install_git_config
    install_ssh_client
    install_helix_config
  fi

  if [[ "$MODE_WSL" == true ]]; then
    log "Tier-0 complete (WSL)"
    return
  fi

  if [[ "$MODE_VPS" == true ]]; then
    run_as_primary_user install_nvm
    run_as_primary_user install_node
    run_as_primary_user install_npm_globals
    prompt_vps_reboot
    return
  fi

  install_nvm
  install_node
  install_npm_globals

  log "Tier-0 complete (Desktop)"
}

main "$@"
