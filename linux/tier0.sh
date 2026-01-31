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

DEFAULT_USER_REMOVAL_SCHEDULED=0

### LOGGING ###################################################################
log() {
  echo "[bootstrap] $*"
}

### MODE FLAGS ###############################################################
MODE_DESKTOP=0
MODE_VPS=0
MODE_WSL=0
DESIRED_HOSTNAME=""

usage() {
  cat <<EOF
Usage: $0 [--desktop | --vps | --wsl]

Exactly one mode must be specified.
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --desktop) MODE_DESKTOP=1 ;;
    --vps)     MODE_VPS=1 ;;
    --wsl)     MODE_WSL=1 ;;
    -h|--help) usage ;;
    *) echo "Unknown argument: $1"; usage ;;
  esac
  shift
done

if [[ "$MODE_VPS" -eq 1 && "$(id -u)" -ne 0 ]]; then
  echo "ERROR: Tier 0 must be run as root in --vps mode"
  exit 1
fi

mode_count=$(( MODE_DESKTOP + MODE_VPS + MODE_WSL ))
[[ "$mode_count" -eq 1 ]] || usage

[[ "$MODE_DESKTOP" -eq 1 ]] && DESIRED_HOSTNAME="desktop"
[[ "$MODE_VPS"     -eq 1 ]] && DESIRED_HOSTNAME="vps"
[[ "$MODE_WSL"     -eq 1 ]] && DESIRED_HOSTNAME="wsl"

### PACKAGE MANAGEMENT ########################################################
pkg_install() {
  apt-get update -y
  apt-get install -y "$@"
}

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

  [[ "$MODE_VPS" -eq 0 ]] && pkgs+=(xclip)
  [[ "$MODE_DESKTOP" -eq 1 ]] && pkgs+=(fonts-firacode)

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
  [[ "$(hostname)" == "$DESIRED_HOSTNAME" ]] && return
  log "Setting hostname to '$DESIRED_HOSTNAME'"
  hostnamectl set-hostname "$DESIRED_HOSTNAME"
}

### CLOUD USER ###############################################################
detect_default_cloud_user() {
  for u in debian ubuntu ec2-user rocky almalinux oracle centos admin; do
    id "$u" &>/dev/null && [[ "$u" != "$PRIMARY_USER" ]] && echo "$u" && return 0
  done
  return 1
}

ensure_primary_user() {
  id "$PRIMARY_USER" &>/dev/null && return

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
  local user
  user="$(detect_default_cloud_user || true)"
  [[ -z "$user" ]] && return

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
  DEFAULT_USER_REMOVAL_SCHEDULED=1
}

### USER CONTEXT EXECUTION ####################################################
run_as_primary_user() {
  local fn="$1"

  sudo -u "$PRIMARY_USER" -H bash -lc "
    set -euo pipefail
    $(declare -f "$fn")
    $fn
  "
}

### USER DOTFILES #############################################################
install_linux_dotfiles() {
  log "Installing Linux dotfiles"
  wget -q -O "$HOME/.bashrc"        "$LINUX_DOTFILES_URL/.bashrc"
  wget -q -O "$HOME/.bash_aliases" "$LINUX_DOTFILES_URL/.bash_aliases"
  wget -q -O "$HOME/.inputrc"      "$LINUX_DOTFILES_URL/.inputrc"
}

install_git_config() {
  log "Installing Git configuration"
  wget -q -O "$HOME/.gitconfig" "$SHARED_GIT_URL/.gitconfig"
  wget -q -O "$HOME/.gitignore_global" "$SHARED_GIT_URL/.gitignore_global"
}

install_ssh_client() {
  log "Setting up SSH client"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
}

install_helix_config() {
  log "Installing Helix configuration"
  mkdir -p "$HOME/.config/helix"
  wget -q -O "$HOME/.config/helix/config.toml" "$SHARED_HELIX_URL/config.toml"
  wget -q -O "$HOME/.config/helix/languages.toml" "$SHARED_HELIX_URL/languages.toml"
}

### NODE ######################################################################
source_nvm() {
  set +u
  source "$HOME/.nvm/nvm.sh"
  set -u
}

install_nvm() {
  [[ -d "$HOME/.nvm" ]] && return
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
}

install_node() {
  source_nvm
  nvm install --lts
  nvm use --lts --delete-prefix
}

install_npm_globals() {
  source_nvm
  npm install -g eslint prettier pnpm typescript
}

### REBOOT ####################################################################
prompt_vps_reboot() {
  [[ "$DEFAULT_USER_REMOVAL_SCHEDULED" -eq 0 ]] && return

  echo
  echo "Tier 0 complete (VPS). Reboot required before Tier 1."
  read -r -p "Reboot now? [y/N] " ans
  [[ "$ans" =~ ^[yY] ]] && reboot
}

### MAIN ######################################################################
main() {
  log "Starting Tier-0"

  install_base_packages
  configure_locale

  if [[ "$MODE_VPS" -eq 1 ]]; then
    ensure_primary_user
    disable_cloud_init_user_management
    schedule_default_user_removal
  fi

  set_hostname

  if [[ "$MODE_VPS" -eq 1 ]]; then
    run_as_primary_user install_linux_dotfiles
    run_as_primary_user install_git_config
    run_as_primary_user install_ssh_client
    run_as_primary_user install_helix_config
    run_as_primary_user install_nvm
    run_as_primary_user install_node
    run_as_primary_user install_npm_globals
    prompt_vps_reboot
    return
  fi

  install_linux_dotfiles
  install_git_config
  install_ssh_client
  install_helix_config
  install_nvm
  install_node
  install_npm_globals

  log "Tier-0 complete"
}

main "$@"
