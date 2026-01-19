# Linux Bootstrap Overview

## Quick Start

| Environment               | Commands to Run                                 | Notes                                             |
| ------------------------- | ----------------------------------------------- | ------------------------------------------------- |
| **Desktop / Workstation** | `tier1 --desktop` → `tier2 --desktop` → `tier3` | GNOME system with browsers, extensions, UX config |
| **VPS / Server**          | `tier1 --vps` → `tier2 --vps`                   | SSH hardening, no desktop components              |
| **WSL**                   | `tier1 --wsl` → `tier2 --wsl`                   | No system services, no sshd                       |

---

This repository provides a **three-tier Linux bootstrap system** designed to safely and reproducibly configure machines across different roles:

* **Desktop / workstation**
* **VPS / server**
* **WSL**

Each tier has a **strict responsibility boundary**. You should run them **in order**, choosing the appropriate mode flags.

---

## Tier 1 – Bootstrap (User Environment)

**Purpose:**
Establish a consistent *user-level* environment with no system services or destructive changes.

**What it does:**

* Installs base tools (`curl`, `wget`, `git`)
* Installs Linux dotfiles (`.bashrc`)
* Installs Git configuration
* Installs SSH *client* configuration
* Installs Helix editor configuration
* Installs NVM, Node.js (LTS), and global npm tools (desktop & VPS only)

**What it does *not* do:**

* No `sshd` changes
* No firewall changes
* No GNOME or desktop configuration
* No system hardening

**Run exactly once per user account.**

### Run Tier 1

```sh
wget -O tier1.sh https://raw.githubusercontent.com/AaronWeinberg/init/master/linux/tier1-bootstrap.sh \
  && chmod +x tier1.sh \
  && ./tier1.sh --desktop   # or --vps | --wsl \
  && rm tier1.sh
```

---

## Tier 2 – Post-Bootstrap (System Configuration)

**Purpose:**
Apply **system-level changes** and install opinionated tools.
This tier has side effects and is **explicitly role-driven**.

**What it does (depending on mode):**

* Installs Helix editor (binary)
* Applies SSH hardening (`sshd`, firewall)
* Enables Byobu
* Installs browsers (desktop only)
* Installs Steam (desktop only)
* Downloads GNOME extensions (desktop only)

**What it does *not* do:**

* No GNOME runtime configuration
* No dconf changes
* No extension enabling

### Modes

| Mode        | Use case                        |
| ----------- | ------------------------------- |
| `--desktop` | Laptop / workstation with GNOME |
| `--vps`     | Server / cloud VM               |
| `--wsl`     | WSL environment (no services)   |

### Run Tier 2

```sh
wget -O tier2.sh https://raw.githubusercontent.com/AaronWeinberg/init/master/linux/tier2-post-bootstrap.sh \
  && chmod +x tier2.sh \
  && ./tier2.sh --desktop   # or --vps | --wsl \
  && rm tier2.sh
```

---

## Tier 3 – Desktop UX (GNOME Only)

**Purpose:**
Configure **GNOME runtime state**. This tier assumes:

* a logged-in GNOME session
* a running display server

**What it does:**

* Applies `dconf` settings
* Explicitly enables GNOME extensions
* Handles GNOME 48 compatibility correctly
* Documents required logout/login (Wayland)

**What it does *not* do:**

* No package installs
* No system services
* No SSH or firewall changes

**Only run on GNOME desktops.**

### Run Tier 3

```sh
wget -O tier3.sh https://raw.githubusercontent.com/AaronWeinberg/init/master/linux/tier3-desktop.sh \
  && chmod +x tier3.sh \
  && ./tier3.sh \
  && rm tier3.sh
```

---

## Recommended Order

For a **desktop workstation**:

1. Tier 1 – bootstrap user environment
2. Tier 2 – system + desktop packages
3. Log out / log in (if prompted)
4. Tier 3 – GNOME configuration

For a **VPS**:

1. Tier 1 – bootstrap user environment
2. Tier 2 – system hardening

For **WSL**:

1. Tier 1 – bootstrap user environment
2. Tier 2 – minimal tooling

---

## Design Principles

* Explicit > implicit (no auto-detection)
* One responsibility per tier
* Idempotent where possible
* Safe to re-run
* No silent failures

---

## Summary

| Tier   | Scope                | Safe to re-run | Role-aware |
| ------ | -------------------- | -------------- | ---------- |
| Tier 1 | User environment     | Yes            | Yes        |
| Tier 2 | System configuration | Mostly         | Yes        |
| Tier 3 | GNOME runtime        | Yes            | GNOME only |

If you’re unsure which tier to modify:

* **User preferences → Tier 1**
* **System changes → Tier 2**
* **Desktop behavior → Tier 3**
