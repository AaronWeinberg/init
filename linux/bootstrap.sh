#!/usr/bin/env bash
#cloud-config
# Idempotent system bootstrap with dry-run support

set -euo pipefail

### CONFIGURATION ############################################################
LINUX_URL="https://example.com/linux"
SHARED_GIT_URL="https://example.com/git"
SHARED_SSH_URL="https://example.com/ssh"
SHARED_HELIX_URL="https://example.com/helix"

DEFAULT_SSH_PORT=22
DRY_RUN=false

### DRY-RUN HANDLING ##########################################################
run() {
  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN] $*"
  else
    eval "$@"
  fi
}

### UTILITIES #################################################################
log() { echo "[INFO] $*"; }

is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

is_kvm() {
  systemd-detect-virt --vm 2>/dev/null | grep -qiE 'kvm|qemu'
}

pkg_install() {
  local pkgs=("$@")
  run "sudo apt-get update -y"
  run "sudo apt-get install -y ${pkgs[*]}"
}

safe_wget() {
  local url="$1" dest="$2"
  run "sudo wget -q -O '$dest' '$url'"
}

### SSH HARDENING MODULE #######################################################
ssh_hardening() {
  log "Applying SSH hardening"

  local port="${SSH_PORT:-$DEFAULT_SSH_PORT}"
  [[ "$port" =~ ^[0-9]+$ ]] || port="$DEFAULT_SSH_PORT"

  safe_wget "$LINUX_URL/sshd_config" "/etc/ssh/sshd_config"

  run "sudo sed -i 's/^#\?Port .*/Port ${port}/' /etc/ssh/sshd_config"
  run "sudo sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config"
  run "sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config"
  run "sudo sed -i 's/^#\?X11Forwarding .*/X11Forwarding no/' /etc/ssh/sshd_config"

  run "sudo sshd -t"
  run "sudo ufw allow ${port}/tcp"
  run "sudo systemctl restart ssh"
}


### DOTFILES ##################################################################
install_dotfiles() {
  log "Installing dotfiles"
  run "wget -q -O ~/.bashrc '$SHARED_GIT_URL/.bashrc'"
  run "wget -q -O ~/.gitconfig '$SHARED_GIT_URL/.gitconfig'"
}

### NVM & NODE ################################################################
install_nvm() {
  if [[ -d "$HOME/.nvm" ]]; then
    log "NVM already installed"
    return
  fi
  log "Installing NVM"
  run "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
}

install_node
  enable_byobu() {
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  run "nvm install --lts"
  run "nvm use --lts"
}

### GNOME EXTENSIONS MODULE ####################################################
install_gnome_extensions() {
  log "Installing GNOME extensions"

  pkg_install jq unzip gnome-shell-extension-manager

  local version
  version=$(gnome-shell --version | awk '{print $3}')

  local extensions=(
    "dash-to-dock@micxgx.gmail.com"
    "user-theme@gnome-shell-extensions.gcampax.github.com"
  )

  for uuid in "${extensions[@]}"; do
    log "Installing extension $uuid"
    run "gnome-extensions install --force $(curl -fsSL https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=${version} | jq -r '.download_url' | sed 's|^|https://extensions.gnome.org|')"
    run "gnome-extensions enable $uuid"
  done
}

### DESKTOP CONFIG #############################################################
configure_desktop() {
  log "Configuring GNOME desktop"
  pkg_install gnome-shell-extension-manager jq unzip
  safe_wget "$LINUX_URL/.dconf" "/tmp/dconf.dump"
  run "dconf load / < /tmp/dconf.dump"
  install_gnome_extensions
}


### SIDE EFFECT MODULES ########################################################
enable_byobu() {
  log "Enabling Byobu"
  pkg_install byobu
  run "byobu-enable"
}

### MAIN ######################################################################
main() {
  for arg in "$@"; do
    case "$arg" in
      --dry-run) DRY_RUN=true ;;
    esac
  done

  log "Starting bootstrap (dry-run=$DRY_RUN)"

  pkg_install curl wget git ufw
  install_dotfiles
  install_nvm
  install_node

  if is_kvm; then
    configure_ssh
  fi

  if ! is_wsl; then
    configure_desktop
  fi

  log "Bootstrap complete"
}

main "$@"
