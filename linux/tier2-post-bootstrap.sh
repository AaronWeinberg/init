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
is_debian() {
  grep -qi debian /etc/os-release 2>/dev/null
}

is_ubuntu() {
  grep -qi ubuntu /etc/os-release 2>/dev/null
}

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

  log "Installing Steam (Debian)"

  if is_debian; then
    log "Enabling contrib and non-free-firmware"

    sudo sed -i \
      's/^\(deb .* main\)$/\1 contrib non-free-firmware/' \
      /etc/apt/sources.list

    sudo dpkg --add-architecture i386
    sudo apt-get update -y
    pkg_install steam

  elif is_ubuntu; then
    log "Installing Steam (Ubuntu)"

    sudo add-apt-repository -y multiverse
    sudo dpkg --add-architecture i386
    sudo apt-get update -y
    pkg_install steam
  else
    log "Unknown distro — skipping Steam"
  fi
}

### GNOME EXTENSIONS ###########################################################
install_gnome_extensions() {
  log "Installing GNOME extensions (Tier-2)"

  pkg_install gnome-shell-extension-manager jq curl

  local uuids=(
    "ddterm@amezin.github.com"
    "aztaskbar@aztaskbar.gitlab.com"
    "autohide-battery@sitnik.ru"
    "autohide-volume@unboiled.info"
    "tilingshell@ferrarodomenico.com"
    "quicksettings-audio-devices-hider@marcinjahn.com"
    "emoji-copy@felipeftn"
  )

  local shell_version
  shell_version="$(gnome-shell --version | awk '{print $3}' | cut -d. -f1)"

  for uuid in "${uuids[@]}"; do
    log "Resolving $uuid for GNOME Shell $shell_version"

    # Query EGO API
    info="$(curl -fsSL "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$shell_version")" || {
      log "Failed to query metadata for $uuid"
      continue
    }

    download_path="$(echo "$info" | jq -r '.download_url')" || true
    [[ -z "$download_path" || "$download_path" == "null" ]] && {
      log "No compatible release for $uuid"
      continue
    }

    tmp="$(mktemp)"
    curl -fsSL "https://extensions.gnome.org$download_path" -o "$tmp" || {
      log "Download failed for $uuid"
      rm -f "$tmp"
      continue
    }

    log "Installing $uuid"
    gnome-extensions install --force "$tmp" || log "Install failed for $uuid"
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
