#!/usr/bin/env bash
#cloud-config
# Tier 0 – minimal, deterministic system bootstrap

set -euo pipefail

### CONFIG ####################################################################
BASE_URL="https://raw.githubusercontent.com/AaronWeinberg/init/master"

SHARED_URL="$BASE_URL/dotfiles/shared"
LINUX_DOTFILES_URL="$BASE_URL/dotfiles/linux"
SHARED_GIT_URL="$SHARED_URL/git"
SHARED_HELIX_URL="$SHARED_URL/helix"

PRIMARY_USER="aaron"
SSH_AUTH_KEYS_URL="$SHARED_URL/ssh/id_ed25519.pub"

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
  echo "Usage: $0 [--desktop | --vps | --wsl]"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --desktop) MODE_DESKTOP=1 ;;
    --vps)     MODE_VPS=1 ;;
    --wsl)     MODE_WSL=1 ;;
    *) usage ;;
  esac
  shift
done

(( MODE_DESKTOP + MODE_VPS + MODE_WSL == 1 )) || usage

[[ "$MODE_DESKTOP" -eq 1 ]] && DESIRED_HOSTNAME="desktop"
[[ "$MODE_VPS"     -eq 1 ]] && DESIRED_HOSTNAME="vps"
[[ "$MODE_WSL"     -eq 1 ]] && DESIRED_HOSTNAME="wsl"

if [[ "$MODE_VPS" -eq 1 && "$(id -u)" -ne 0 ]]; then
  echo "ERROR: --vps mode must be run as root"
  exit 1
fi

### PACKAGES ##################################################################
pkg_install() {
  apt-get update -y
  apt-get install -y "$@"
}

install_base_packages() {
  log "Installing base packages"

  local pkgs=(
    ca-certificates curl dos2unix git htop wget
    python3 python3-pip python3-venv build-essential
  )

  [[ "$MODE_VPS" -eq 0 ]] && pkgs+=(xclip)
  [[ "$MODE_DESKTOP" -eq 1 ]] && pkgs+=(fonts-firacode)

  pkg_install "${pkgs[@]}"
}

### LOCALE ####################################################################
configure_locale() {
  log "Configuring locale"

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

### USERS #####################################################################
detect_default_cloud_user() {
  for u in debian ubuntu ec2-user rocky almalinux oracle centos admin; do
    id "$u" &>/dev/null && [[ "$u" != "$PRIMARY_USER" ]] && echo "$u" && return
  done
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
ExecStart=/usr/sbin/deluser --remove-home $user
ExecStartPost=/bin/rm -f /etc/systemd/system/remove-default-user.service
ExecStartPost=/bin/systemctl daemon-reload

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable remove-default-user.service
  DEFAULT_USER_REMOVAL_SCHEDULED=1
}

### USER-SCOPED (PURE) ########################################################
run_as_primary_user() {
  sudo -u "$PRIMARY_USER" -H bash -lc "$1"
}

user_install_dotfiles() {
  wget -q -O "$HOME/.bashrc"        "$LINUX_DOTFILES_URL/.bashrc"
  wget -q -O "$HOME/.bash_aliases" "$LINUX_DOTFILES_URL/.bash_aliases"
  wget -q -O "$HOME/.inputrc"      "$LINUX_DOTFILES_URL/.inputrc"
}

user_install_git() {
  wget -q -O "$HOME/.gitconfig" "$SHARED_GIT_URL/.gitconfig"
  wget -q -O "$HOME/.gitignore_global" "$SHARED_GIT_URL/.gitignore_global"
}

user_install_helix() {
  mkdir -p "$HOME/.config/helix"
  wget -q -O "$HOME/.config/helix/config.toml" "$SHARED_HELIX_URL/config.toml"
  wget -q -O "$HOME/.config/helix/languages.toml" "$SHARED_HELIX_URL/languages.toml"
}

user_install_nvm() {
  [[ -d "$HOME/.nvm" ]] && return
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
}

user_install_node() {
  set +u
  source "$HOME/.nvm/nvm.sh"
  set -u
  nvm install --lts
  nvm use --lts --delete-prefix
}

user_install_npm_globals() {
  set +u
  source "$HOME/.nvm/nvm.sh"
  set -u
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
    log "Installing user dotfiles"
    run_as_primary_user user_install_dotfiles

    log "Installing git config"
    run_as_primary_user user_install_git

    log "Installing Helix config"
    run_as_primary_user user_install_helix

    log "Installing Node toolchain"
    run_as_primary_user user_install_nvm
    run_as_primary_user user_install_node
    run_as_primary_user user_install_npm_globals

    prompt_vps_reboot
    return
  fi

  user_install_dotfiles
  user_install_git
  user_install_helix
  user_install_nvm
  user_install_node
  user_install_npm_globals

  log "Tier-0 complete"
}

main "$@"
