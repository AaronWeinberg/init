#!/usr/bin/env bash
# Tier 2 – Post-Bootstrap
# Explicit, role-based configuration with side effects

set -euo pipefail

### CONFIG ####################################################################
BASE_URL="https://raw.githubusercontent.com/AaronWeinberg/init/master"
LINUX_URL="$BASE_URL/linux"
DOTFILES_URL="$LINUX_URL/dotfiles"

DEFAULT_SSH_PORT=22
SSH_PORT=""

GO_VERSION="1.22.1"
GO_TARBALL="go${GO_VERSION}.linux-amd64.tar.gz"

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
Usage: $0 [--desktop | --vps | --wsl] [--ssh-port PORT]

  --desktop        Desktop / workstation setup
  --vps            Server / VPS setup (SSH hardening only)
  --wsl            WSL environment
  --ssh-port PORT  SSH port (VPS mode only, optional)

Exactly one mode must be specified.
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --desktop) MODE_DESKTOP=true ;;
    --vps)     MODE_VPS=true ;;
    --wsl)     MODE_WSL=true ;;
    --ssh-port)
      SSH_PORT="${2:-}"
      shift
      ;;
    -h|--help) usage ;;
    *) echo "Unknown argument: $1"; usage ;;
  esac
  shift
done

mode_count=0
[[ "$MODE_DESKTOP" == true ]] && ((mode_count+=1))
[[ "$MODE_VPS" == true ]]     && ((mode_count+=1))
[[ "$MODE_WSL" == true ]]     && ((mode_count+=1))

[[ "$mode_count" -ne 1 ]] && usage

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

### GO ########################################################################
install_go() {
  command -v go >/dev/null && return

  log "Installing Go ${GO_VERSION}"

  curl -fsSL "https://go.dev/dl/${GO_TARBALL}" -o "/tmp/${GO_TARBALL}"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "/tmp/${GO_TARBALL}"
  rm -f "/tmp/${GO_TARBALL}"

  log "Go installed"
}

### SSH HARDENING #############################################################
ssh_hardening() {
  log "Applying SSH hardening"

  pkg_install openssh-server

  local port_conf="/etc/ssh/sshd_config.d/99-port.conf"

  # Apply port override only if explicitly provided
  if [[ -n "${SSH_PORT:-}" ]]; then
    local port="$SSH_PORT"

    # Validate provided port
    if ! [[ "$port" =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
      echo "ERROR: Invalid SSH port: $port"
      exit 1
    fi

    log "Setting SSH port to ${port} via drop-in config"

    echo "Port ${port}" | sudo tee "$port_conf" >/dev/null
    sudo chmod 644 "$port_conf"
  else
    log "No --ssh-port provided — leaving SSH port unchanged"
  fi

  # Validate SSH configuration before restart
  sudo /usr/sbin/sshd -t

  pkg_install ufw

  # Open firewall port only if we set one
  if [[ -n "${SSH_PORT:-}" ]]; then
    sudo ufw allow "${SSH_PORT}/tcp"
  fi

  sudo systemctl restart ssh

  # Log effective SSH port
  local effective_port
  effective_port="$(sudo sshd -T | awk '/^port / {print $2}')"
  log "Effective SSH port: ${effective_port}"

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
    "autohide-volume@unboiled.info"
    "ddterm@amezin.github.com"
    "tilingshell@ferrarodomenico.com"
    "quicksettings-audio-devices-hider@marcinjahn.com"
    "emoji-copy@felipeftn"
  )

  local shell_version
  shell_version="$(gnome-shell --version | awk '{print $3}' | cut -d. -f1)"

  for uuid in "${uuids[@]}"; do
    local info
    info="$(curl -fsSL \
      "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$shell_version" || true)"

    local download_path
    download_path="$(echo "$info" | jq -r '.download_url')"

    [[ -z "$download_path" || "$download_path" == "null" ]] && continue

    local tmp
    tmp="$(mktemp)"
    curl -fsSL "https://extensions.gnome.org$download_path" -o "$tmp"
    gnome-extensions install --force "$tmp" || true
    rm -f "$tmp"
  done
}

### MAIN ######################################################################
main() {
  log "Starting Tier-2 post-bootstrap"

  install_helix

  if [[ "$MODE_WSL" == true ]]; then
    install_go
    log "Post-bootstrap complete (WSL)"
    return
  fi

  if [[ "$MODE_VPS" == true ]]; then
    ssh_hardening
    log "Post-bootstrap complete (VPS)"
    return
  fi

  if [[ "$MODE_DESKTOP" == true ]]; then
    install_go
    enable_byobu

    if require_desktop; then
      install_chrome
      install_edge
      install_steam
      install_gnome_extensions
    fi

    log "Post-bootstrap complete (Desktop)"
  fi
}

main "$@"
