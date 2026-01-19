#!/usr/bin/env bash
# Tier 2 – Post-Bootstrap
# Explicit, role-based configuration with side effects
#
# Modes (exactly one required):
#   --desktop   Workstation / GNOME system
#   --vps       Server / VPS (sshd only, no desktop)
#   --wsl       WSL environment (no sshd, no system services)

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

### MODE FLAGS ###############################################################
MODE_DESKTOP=false
MODE_VPS=false
MODE_WSL=false

usage() {
  cat <<EOF
Usage: $0 [--desktop | --vps | --wsl]

  --desktop   Desktop / workstation setup (GNOME, browsers, Steam)
  --vps       Server / VPS setup (SSH hardening only)
  --wsl       WSL environment (no sshd, no system services)

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

mode_count=0

if [[ "$MODE_DESKTOP" == true ]]; then
  ((mode_count+=1))
fi

if [[ "$MODE_VPS" == true ]]; then
  ((mode_count+=1))
fi

if [[ "$MODE_WSL" == true ]]; then
  ((mode_count+=1))
fi

if [[ "$mode_count" -ne 1 ]]; then
  usage
fi

### PLATFORM ##################################################################
require_desktop() {
  [[ -n "${DISPLAY:-}" ]]
}

### PACKAGE MANAGEMENT ########################################################
pkg_install() {
  sudo apt-get update -y
  sudo apt-get install -y "$@"
}

### HELIX #####################################################################
install_helix() {
  command -v hx >/dev/null && return
  log "Installing Helix editor"
  pkg_install hx
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

### STEAM ######################################################################
install_steam() {
  command -v steam >/dev/null && return

  log "Installing Steam"

  # Enable i386 architecture (idempotent)
  if ! dpkg --print-foreign-architectures | grep -qx i386; then
    sudo dpkg --add-architecture i386
  fi

  sudo apt-get update -y
  pkg_install steam-installer
}

### GNOME EXTENSIONS ###########################################################
install_gnome_extensions() {
  log "Installing GNOME extensions (Tier-2)"

  pkg_install gnome-shell-extension-manager curl jq

  local uuids=(
    "autohide-battery@sitnik.ru"
    # "aztaskbar@aztaskbar.gitlab.com"   # GNOME 48 incompatible
    "autohide-volume@unboiled.info"
    "ddterm@amezin.github.com"
    "tilingshell@ferrarodomenico.com"
    "quicksettings-audio-devices-hider@marcinjahn.com"
    "emoji-copy@felipeftn"
  )

  local shell_version
  shell_version="$(gnome-shell --version | awk '{print $3}' | cut -d. -f1)"
  log "Detected GNOME Shell $shell_version"

  for uuid in "${uuids[@]}"; do
    log "Resolving extension $uuid"

    local info
    if ! info="$(curl -fsSL \
      "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$shell_version")"; then
      log "Metadata query failed for $uuid"
      continue
    fi

    local download_path
    download_path="$(echo "$info" | jq -r '.download_url')"

    if [[ -z "$download_path" || "$download_path" == "null" ]]; then
      log "No compatible release for $uuid"
      continue
    fi

    local tmp
    tmp="$(mktemp)"
    curl -fsSL "https://extensions.gnome.org$download_path" -o "$tmp"

    log "Installing $uuid"
    gnome-extensions install --force "$tmp" || true
    rm -f "$tmp"
  done
}

### MAIN ######################################################################
main() {
  log "Starting Tier-2 post-bootstrap"

  install_helix

  if [[ "$MODE_WSL" == true ]]; then
    log "Mode: WSL — skipping sshd and desktop components"
    log "Post-bootstrap complete (WSL)"
    return
  fi

  if [[ "$MODE_VPS" == true ]]; then
    log "Mode: VPS"
    ssh_hardening
    log "Post-bootstrap complete (VPS)"
    return
  fi

  if [[ "$MODE_DESKTOP" == true ]]; then
    log "Mode: Desktop"

    enable_byobu

    if require_desktop; then
      install_chrome
      install_edge
      install_steam
      install_gnome_extensions
    else
      log "No desktop detected — skipping desktop packages"
    fi

    log "Post-bootstrap complete (Desktop)"
    return
  fi
}

main "$@"
