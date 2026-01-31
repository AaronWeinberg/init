#!/usr/bin/env bash
#cloud-config
# Tier 0 – minimal, deterministic system bootstrap

set -euo pipefail

### CONFIG ####################################################################
BASE_URL="https://raw.githubusercontent.com/AaronWeinberg/init/master"

LINUX_DOTFILES_URL="$BASE_URL/dotfiles/linux"
SHARED_GIT_URL="$BASE_URL/dotfiles/shared/git"
SHARED_HELIX_URL="$BASE_URL/dotfiles/shared/helix"
SSH_AUTH_KEYS_URL="$BASE_URL/dotfiles/shared/ssh/id_ed25519.pub"

PRIMARY_USER="aaron"
DEFAULT_USER_REMOVAL_SCHEDULED=0

### LOGGING ###################################################################
log() {
  echo "[bootstrap] $*"
}

### MODE FLAGS ###############################################################
MODE_VPS=0
MODE_DESKTOP=0
MODE_WSL=0

usage() {
  echo "Usage: $0 [--vps | --desktop | --wsl]"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vps) MODE_VPS=1 ;;
    --desktop) MODE_DESKTOP=1 ;;
    --wsl) MODE_WSL=1 ;;
    *) usage ;;
  esac
  shift
done

(( MODE_VPS + MODE_DESKTOP + MODE_WSL == 1 )) || usage

if [[ "$MODE_VPS" -eq 1 && "$(id -u)" -ne 0 ]]; then
  echo "ERROR: --vps must be run as root"
  exit 1
fi

### PACKAGES ##################################################################
apt-get update -y
apt-get install -y \
  ca-certificates curl dos2unix git htop wget \
  python3 python3-pip python3-venv build-essential \
  locales

### LOCALE ####################################################################
log "Configuring locale"
sed -i \
  -e 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' \
  -e 's/^# *en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' \
  /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8

### USERS #####################################################################
if [[ "$MODE_VPS" -eq 1 ]]; then
  if ! id "$PRIMARY_USER" &>/dev/null; then
    log "Creating primary user '$PRIMARY_USER'"
    adduser --disabled-password --gecos "" "$PRIMARY_USER"
    usermod -aG sudo "$PRIMARY_USER"

    install -d -m 700 "/home/$PRIMARY_USER/.ssh"
    curl -fsSL "$SSH_AUTH_KEYS_URL" \
      -o "/home/$PRIMARY_USER/.ssh/authorized_keys"
    chown -R "$PRIMARY_USER:$PRIMARY_USER" "/home/$PRIMARY_USER/.ssh"
    chmod 600 "/home/$PRIMARY_USER/.ssh/authorized_keys"
  fi

  log "Disabling cloud-init user management"
  mkdir -p /etc/cloud/cloud.cfg.d
  tee /etc/cloud/cloud.cfg.d/99-disable-user-management.cfg >/dev/null <<EOF
users: []
disable_root: true
preserve_hostname: true
EOF

  if id debian &>/dev/null; then
    log "Scheduling removal of 'debian' on next boot"
    tee /etc/systemd/system/remove-default-user.service >/dev/null <<EOF
[Unit]
Description=Remove default cloud user
After=multi-user.target cloud-init.service

[Service]
Type=oneshot
ExecStart=/usr/sbin/deluser --remove-home debian
ExecStartPost=/bin/rm -f /etc/systemd/system/remove-default-user.service
ExecStartPost=/bin/systemctl daemon-reload

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable remove-default-user.service
    DEFAULT_USER_REMOVAL_SCHEDULED=1
  fi
fi

### USER ENV SETUP ############################################################
if [[ "$MODE_VPS" -eq 1 ]]; then
  log "Installing user dotfiles"
  sudo -u "$PRIMARY_USER" -H bash -lc "
    wget -q -O \"\$HOME/.bashrc\" \"$LINUX_DOTFILES_URL/.bashrc\"
    wget -q -O \"\$HOME/.bash_aliases\" \"$LINUX_DOTFILES_URL/.bash_aliases\"
    wget -q -O \"\$HOME/.inputrc\" \"$LINUX_DOTFILES_URL/.inputrc\"

    wget -q -O \"\$HOME/.gitconfig\" \"$SHARED_GIT_URL/.gitconfig\"
    wget -q -O \"\$HOME/.gitignore_global\" \"$SHARED_GIT_URL/.gitignore_global\"

    mkdir -p \"\$HOME/.config/helix\"
    wget -q -O \"\$HOME/.config/helix/config.toml\" \"$SHARED_HELIX_URL/config.toml\"
    wget -q -O \"\$HOME/.config/helix/languages.toml\" \"$SHARED_HELIX_URL/languages.toml\"

    if [[ ! -d \"\$HOME/.nvm\" ]]; then
      curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    fi

    set +u
    source \"\$HOME/.nvm/nvm.sh\"
    set -u
    nvm install --lts
    npm install -g eslint prettier pnpm typescript
  "
fi

### REBOOT ####################################################################
if [[ "$DEFAULT_USER_REMOVAL_SCHEDULED" -eq 1 ]]; then
  echo
  echo "Tier 0 complete (VPS). Reboot required before Tier 1."
  read -r -p "Reboot now? [y/N] " ans
  [[ "$ans" =~ ^[yY] ]] && reboot
fi

log "Tier-0 complete"
