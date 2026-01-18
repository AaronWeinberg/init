#!/usr/bin/env bash
# Tier 2 Post-Bootstrap
# Explicit, user-invoked configuration with side effects

set -euo pipefail

### CONFIG ####################################################################
BASE_URL="https://raw.githubusercontent.com/AaronWeinberg/init/master"
LINUX_URL="$BASE_URL/linux"
DOTFILES_URL="$LINUX_URL/dotfiles"

DEFAULT_SSH_PORT=22

### LOGGING ###################################################################
log() {
  echo "[post-bootstrap] $*"
}

### PLATFORM ##################################################################
is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

require_desktop() {
  [[ -n "${DISPLAY:-}" ]]
}

### PACKAGE MANAGEMENT ########################################################
pkg_install() {
  local pkgs=("$@")
  sudo apt-get update -y
  sudo apt-get install -y "${pkgs[@]}"
}

### SSH HARDENING #############################################################
ssh_hardening() {
  log "Applying SSH hardening"

  pkg_install openssh-server

  local port
  read -rp "Enter SSH port for this host [${DEFAULT_SSH_PORT}]: " port
  port="${port:-$DEFAULT_SSH_PORT}"

  if ! [[ "$port" =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
    echo "Invalid SSH port: $port"
    exit 1
  fi

  log "Using SSH port: $port"

  sudo wget -q -O /etc/ssh/sshd_config "$DOTFILES_URL/sshd_config"
  sudo sed -i "s/^#\?Port .*/Port ${port}/" /etc/ssh/sshd_config
  sudo /usr/sbin/sshd -t

  pkg_install ufw
  sudo ufw allow "${port}/tcp"
  sudo systemctl restart ssh

  log "SSH hardening complete"
}

### BYOBU #####################################################################
enable_byobu() {
  log "Enabling Byobu"
  pkg_install byobu
  byobu-enable
}

### BROWSERS ##################################################################
install_chrome() {
  command -v google-chrome >/dev/null && return
  log "Installing Google Chrome"

  wget -qO - https://dl.google.com/linux/linux_signing_key.pub \
    | sudo gpg --dearmor -o /usr/share/keyrings/google-linux.gpg

  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux.gpg] \
https://dl.google.com/linux/chrome/deb/ stable main" \
    | sudo tee /etc/apt/sources.list.d/google-chrome.list

  pkg_install google-chrome-stable
}

install_edge() {
  command -v microsoft-edge >/dev/null && return
  log "Installing Microsoft Edge"

  wget -qO - https://packages.microsoft.com/keys/microsoft.asc \
    | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg

  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] \
https://packages.microsoft.com/repos/edge stable main" \
    | sudo tee /etc/apt/sources.list.d/microsoft-edge.list

  pkg_install microsoft-edge-stable
}

### STEAM #####################################################################
install_steam() {
  command -v steam >/dev/null && return

  log "Installing Steam"

  # Required for add-apt-repository
  pkg_install software-properties-common

  # Enable multiverse (required for Steam)
  sudo add-apt-repository -y multiverse
  sudo apt-get update -y

  sudo dpkg --add-architecture i386
  pkg_install steam
}

### GNOME EXTENSIONS ###########################################################
install_gnome_extensions() {
  log "Installing GNOME extensions (Tier-2)"

  pkg_install gnome-shell-extension-manager

  local urls=(
    "https://extensions.gnome.org/extension-data/ddtermamezin.github.com.v62.0.2.shell-extension.zip"
    "https://extensions.gnome.org/extension-data/aztaskbaraztaskbar.gitlab.com.v31.0.shell-extension.zip"
    "https://extensions.gnome.org/extension-data/autohide-batterysitnik.ru.v58.shell-extension.zip"
    "https://extensions.gnome.org/extension-data/autohide-volumeunboiled.info.v11.shell-extension.zip"
    "https://extensions.gnome.org/extension-data/tilingshellferrarodomenico.com.v17.2.shell-extension.zip"
    "https://extensions.gnome.org/extension-data/quicksettings-audio-devices-hidermarcinjahn.com.v17.shell-extension.zip"
    "https://extensions.gnome.org/extension-data/emoji-copyfelipeftn.v33.shell-extension.zip"
  )

  for url in "${urls[@]}"; do
    log "Downloading $url"
    tmp="$(mktemp)"
    if curl -fsSL "$url" -o "$tmp"; then
      gnome-extensions install --force "$tmp" || log "Install failed for $url"
    else
      log "Download failed for $url"
    fi
    rm -f "$tmp"
  done
}


### MAIN ######################################################################
main() {
  log "Starting Tier-2 post-bootstrap"

  if is_wsl; then
    log "WSL detected — skipping post-bootstrap"
    exit 0
  fi

  ssh_hardening
  enable_byobu

  if require_desktop; then
    install_chrome
    install_edge
    install_steam
    install_gnome_extensions
  else
    log "No desktop detected — skipping desktop packages"
  fi

  log "Post-bootstrap complete"
}

main "$@"
