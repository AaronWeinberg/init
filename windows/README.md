# Windows Init Scripts

A **tiered, explicit Windows setup workflow** for clean installs.

This directory contains **standalone PowerShell scripts** that configure Windows in clearly defined phases.  
Each tier is run **manually and intentionally**. Reboots are **explicit boundaries**, not hidden behavior.

There is no automatic resume across restarts.

---

## Overview

Windows setup is split into **tiers**, each with a narrow, well-defined responsibility:

| Tier | Purpose |
|----|----|
| Tier 0 | OS foundation and system policy |
| Tier 1 | Core tooling and sane defaults |
| Tier 2 | Personal and opinionated setup |
| Tier 3 | Experimental or optional tweaks |

Each tier is a **separate script**. You run them in order.

---

## Prerequisites

- Windows 11 (tested)
- PowerShell run **as Administrator**
- Internet connectivity
- A clean or freshly reset system

---

## 🧱 Tier 0 — OS Foundation

**Run once per install. Reboot required.**

### Responsibilities

- Windows Update (OS-level)
- OEM firmware tooling (Dell Command Update, if applicable)
- System-wide registry policies
- Explorer namespace cleanup
- Keyboard filter driver installation (Ctrl2Cap)
- **Complete OneDrive removal and policy blocking**

This tier establishes a **stable, predictable OS baseline**.

### Run

```powershell
Set-ExecutionPolicy Unrestricted -Scope Process -Force

Invoke-WebRequest `
  https://raw.githubusercontent.com/AaronWeinberg/init/master/windows/tier0.ps1 `
  -OutFile tier0.ps1

.\tier0.ps1

➡ **Reboot immediately after Tier 0 completes.**

---

## 🧰 Tier 1 — Core Tooling & Sane Defaults

**Safe to re-run. No reboot expected.**

### Responsibilities

* Core applications (editor, browsers, utilities)
* Dark mode (system + apps)
* Taskbar cleanup (search, widgets, chat)
* Explorer visibility (file extensions, hidden/system files)
* Notification suppression
* Optional Windows Update policies
* PowerShell profile installation

This tier makes the system **pleasant and usable**, without applying personal identity.

### Run

```powershell
Invoke-WebRequest `
  https://raw.githubusercontent.com/AaronWeinberg/init/master/windows/tier1.ps1 `
  -OutFile tier1.ps1

.\tier1.ps1
```

---

## 🎮 Tier 2 — Personal & Opinionated

**Optional. Destructive by design. Safe to skip.**

### Responsibilities

* Gaming stack (Steam, Battle.net, addons)
* Peripheral software
* Dotfiles:

  * Git
  * Helix
  * Windows Terminal
  * SSH public key
* Bloatware removal
* Startup pruning (known offenders)
* NVIDIA container service disabling

This tier explicitly answers:

> *“This machine is mine.”*

### Run

```powershell
Invoke-WebRequest `
  https://raw.githubusercontent.com/AaronWeinberg/init/master/windows/tier2.ps1 `
  -OutFile tier2.ps1

.\tier2.ps1
```

---

## 🧪 Tier 3 — Experimental (Optional)

Tier 3 is reserved for:

* Aggressive tuning
* Experimental registry changes
* Laptop / desktop divergence
* Changes you may revert later

Nothing critical should live here.

---

## Intentionally Manual Steps

The following are **not automated by design**:

* Night light
* Wallpaper / slideshow
* Browser login and extension sync
* Printer driver setup
* WireGuard tunnel import
* Final startup app review

These are either user-specific, timing-sensitive, or better handled interactively.

---

## Reboot Model (Important)

* **Tier 0 ends at a reboot boundary**
* No script resumes automatically after restart
* Each tier is run in a fresh PowerShell session
* This avoids hidden state and “haunted” behavior

---

## Philosophy

* No implicit state
* No hidden persistence
* No automatic resume across reboot
* Clear, auditable side effects
* Manual control over destructive steps
* Safe to re-run where appropriate

If something modifies the system, it is:

* Explicit
* Logged
* Intentional
