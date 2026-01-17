# Init Scripts & System Setup

A reproducible, deterministic setup workflow for Linux desktops, VPS environments, and Windows systems.
This repository contains **explicit, auditable, idempotent scripts** designed to bootstrap a clean system with minimal assumptions and no hidden state.

The Linux bootstrap script is:

* **Idempotent** (safe to re-run)
* **Cloud-init compatible**
* **Non-interactive**
* **Dry-run capable**
* Modular, with all side-effects isolated and explicit

---

## 🐧 Linux Desktop Setup (GNOME)

### Save Current Settings (Before Reinstall)

Run this **once** on your existing system to capture GNOME state:

```sh
dconf dump / > .dconf
```

Commit `.dconf` to this repository so it can be restored automatically.

---

### Run Bootstrap Script

```sh
wget -O bootstrap.sh https://raw.githubusercontent.com/AaronWeinberg/init/master/linux/bootstrap.sh \
  && chmod +x bootstrap.sh \
  && ./bootstrap.sh \
  && rm bootstrap.sh
```

### Dry-Run (No Changes)

```sh
./bootstrap.sh --dry-run
```

This prints every command that *would* run without modifying the system.

---

### What the Linux Script Does

**Core**

* Installs base packages (`curl`, `wget`, `git`, `ufw`)
* Installs dotfiles (`.bashrc`, `.gitconfig`)
* Installs NVM + Node LTS
* Enables Byobu (explicit side effect)

**Desktop (non-WSL only)**

* Restores GNOME settings from `.dconf`
* Installs GNOME extension tooling
* Installs & enables:

  * Dash-to-Dock
  * User Themes

**VPS / Virtualized Hosts**

* Applies SSH hardening:

  * Custom port
  * Key-only auth
  * Root login disabled
  * Config validated before restart

All behavior is explicit and repeatable.

---

## 🖥️ VPS Setup

### Optional: Change Username (Before Running Bootstrap)

```sh
sudo groupadd new_username
sudo usermod -l new_username old_username
sudo mv /home/old_username /home/new_username
sudo usermod -d /home/new_username new_username
sudo chown -R new_username:new_username /home/new_username
```

Log out and back in **before** running the bootstrap script.

---

### Run Bootstrap (VPS)

```sh
wget -O bootstrap.sh https://raw.githubusercontent.com/AaronWeinberg/init/master/init/linux/bootstrap.sh \
  && chmod +x bootstrap.sh \
  && ./bootstrap.sh \
  && rm bootstrap.sh
```

The script will automatically:

* Detect virtualization
* Harden SSH safely
* Avoid desktop-only steps

---

### SSH Notes (Important)

* SSH configuration is **validated with `sshd -t` before restart**
* Firewall rules are applied before restarting SSH
* If SSH fails validation, the service is **not restarted**

---

## ☁️ Cloud-Init Usage

The Linux script is cloud-init safe and non-interactive.

### Example cloud-init config

```yaml
#cloud-config
runcmd:
  - [ bash, /usr/local/bin/bootstrap.sh ]
```

### Dry-Run via Cloud-Init

```yaml
#cloud-config
runcmd:
  - [ bash, /usr/local/bin/bootstrap.sh, --dry-run ]
```

---

## 🚀 Bare-Repo Deployment (“DIY Heroku”)

### Create Bare Repo

```sh
mkdir -p ~/Development/myProj.git
cd ~/Development/myProj.git
git init --bare
```

### Add Post-Receive Hook

```sh
cd hooks
touch post-receive
chmod u+x post-receive
```

**post-receive**

```sh
#!/usr/bin/env bash
set -euo pipefail

proj=~/Development/myProj
rm -rf "$proj"
mkdir -p "$proj"

echo "Checking out to $proj"
git --work-tree="$proj" checkout -f

echo "Deployment complete"
```

### Add Remote From Local Machine

```sh
git remote add prod box1:~/Development/myProj.git
git push prod
```

---

## 🪟 Windows Setup

### Run Init Script (PowerShell as Administrator)

```powershell
Set-ExecutionPolicy Unrestricted -Scope Process -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AaronWeinberg/init/master/windows/init.ps1" -OutFile init.ps1
.\init.ps1
Remove-Item init.ps1
```

---

## ⚙️ Windows Configuration Checklist

*(unchanged, manual by design)*

* System

  * Night light: **On**
  * Notifications: **Off**
* Personalization

  * Theme: **Dark**
  * Background slideshow (OneDrive)
* Taskbar

  * Disable search, widgets, chat
* Apps

  * Startup: **Disable all**
* Privacy & Security

  * Show file extensions
  * Show hidden/system files
* Windows Update

  * Enable optional updates

---

## 🔧 Common Setup

### Printer Drivers

* **Linux:**
  [https://support.brother.com/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2690dw_us&os=128&dlid=dlf006893_000&flang=4&type3=625](https://support.brother.com/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2690dw_us&os=128&dlid=dlf006893_000&flang=4&type3=625)
* **Windows:**
  [https://support.brother.com/g/b/downloadtop.aspx?c=us&lang=en&prod=mfcl2690dw_us](https://support.brother.com/g/b/downloadtop.aspx?c=us&lang=en&prod=mfcl2690dw_us)

### Browsers

* Install extensions and sync settings for:

  * Edge
  * Firefox
  * Chrome

### Networking

* Import WireGuard tunnel from `.conf` file

---

## Philosophy

* No implicit state
* No magic prompts
* All side effects are isolated and intentional
* Safe to re-run
* Easy to audit

If something changes your system, it’s in a function and named clearly.
