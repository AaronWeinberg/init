# Init Scripts & System Setup

A reproducible, deterministic setup workflow for Linux, Windows, and VPS environments.  
This repository contains explicit, auditable scripts and configuration files designed to bootstrap a clean system with minimal assumptions and zero hidden state.

---

## 🐧 Linux Setup

### Save Current Settings (Before Reinstall)
```sh
dconf dump / > .dconf
```

### Run Init Script
```sh
wget -O init.sh https://raw.githubusercontent.com/AaronWeinberg/init/master/init/linux/init.sh \
  && sudo chmod +x init.sh \
  && ./init.sh \
  && rm init.sh
```

---

## 🖥️ VPS Setup

### Change Username
```sh
sudo groupadd new_username
sudo usermod -l new_username old_username
sudo mv /home/old_username /home/new_username
sudo usermod -d /home/new_username new_username
sudo chown -R new_username:new_username /home/new_username
```

### Update Domains in Caddyfile
Adjust domain entries in your `Caddyfile` as needed.

---

## 🚀 Bare‑Repo Deployment (“DIY Heroku”)

### Create Bare Repo
```sh
mkdir -p ~/Development/myProj.git
cd ~/Development/myProj.git
git init --bare
```

### Add Post‑Receive Hook
```sh
cd hooks
touch post-receive
chmod u+x post-receive
```

**post-receive**
```sh
set -eu
proj=~/Development/myProj
rm -rf "$proj"
mkdir -p "$proj"
echo "checkout to $proj"
git --work-tree="$proj" checkout -f
echo "prod installed"
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
Set-ExecutionPolicy Unrestricted; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AaronWeinberg/init/master/init/windows/init.ps1" -OutFile init.ps1; .\init.ps1; rm init.ps1
```

---

## ⚙️ Windows Configuration Checklist

### System
- Night light: **On**
- Notifications: **Off**
- Additional notification settings: **All off**
- Multitasking → Tabs from apps: **Don’t show tabs**

### Bluetooth & Devices
- Add: keyboard, mouse, controller

### Personalization
- Theme: **Dark**
- Desktop icons → Recycle Bin: **Off**
- Background:
  - Slideshow: `C:\Users\aaron\OneDrive\Backgrounds`
  - Change every **1 minute**
  - Shuffle: **On**
- Lock screen:
  - Slideshow: same folder
  - Fun facts/tips: **Off**
- Start menu:
  - Recently added apps: **Off**
  - Recently opened items: **Off**
  - Tips: **Off**
- Taskbar:
  - Disable: search, task view, widgets, chat

### Apps
- Startup: **Disable all**

### Accounts
- Sign‑in options:
  - Facial recognition
  - Fingerprint

### Time & Language
- Time zone: **Automatic**
- Regional format: **yyyy‑mm‑dd**, **24‑hour time**

### Privacy & Security
- For Developers → File Explorer:
  - Show file extensions: **On**
  - Show hidden/system files: **On**
  - Show full path in title bar: **On**

### Windows Update
- Get latest updates ASAP: **On**
- Advanced options:
  - Microsoft product updates: **On**
  - Optional updates: install

### Additional Windows Setup
- OneDrive → Backgrounds → **Always keep on this device**
- Dell Command Update → run updates
- File Explorer:
  - Remove from Quick Access: Pictures, Music, Videos
- Unpin all apps from taskbar and Start menu

---

## 🔧 Common Setup

### Printer Drivers
- **Linux:**  
  https://support.brother.com/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2690dw_us&os=128&dlid=dlf006893_000&flang=4&type3=625
- **Windows:**  
  https://support.brother.com/g/b/downloadtop.aspx?c=us&lang=en&prod=mfcl2690dw_us

### Browsers
- Install extensions and sync settings for:
  - Edge
  - Firefox
  - Chrome

### Networking
- Import WireGuard tunnel from `.conf` file
