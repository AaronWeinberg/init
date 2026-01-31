# init

A personal, deterministic system bootstrap repository for **Linux** and **Windows**.

This repository exists to make new machines boring.

It provides a small set of **explicit, auditable initialization scripts** that transform a fresh OS install into a predictable, usable environment — without hidden state, background automation, or opaque tooling.

---

## What This Is

- A **reproducible starting point** for new systems
- A way to encode *how I want my machines to behave*
- A guard against configuration drift
- A replacement for “I’ll remember to set that later”

This is **not** a general-purpose provisioning framework.
It is intentionally opinionated and personal.

---

## Design Principles

Across all platforms, the same rules apply:

- **Explicit over clever**
- **Manual phase boundaries** (especially around reboots)
- **No implicit persistence**
- **No background agents**
- **No “resume magic”**
- **No side effects without a name**

If something modifies the system, it is:
- Intentional
- Logged
- Reviewable in the script that caused it

---

## Platform Overview

### 🐧 Linux

Linux initialization is **tiered**, with each tier representing a distinct phase of system setup.

The same tiering philosophy used on Windows applies here:
- Clear responsibility boundaries
- Explicit sequencing
- No hidden state
- No implicit continuation across reboots

The Linux tiers are designed to work across:
- Desktop workstations
- VPS / virtualized hosts
- WSL environments
- Cloud-init contexts

Key characteristics:

- Idempotent (safe to re-run)
- Non-interactive by default
- Dry-run capable
- Environment-aware (desktop vs VPS vs WSL)
- Explicit SSH hardening with validation
- Explicit reboot boundaries where required (e.g. VPS user handoff)

Linux favors **declarative convergence** where possible, but still enforces
manual phase boundaries when the OS requires them.

---

### 🪟 Windows

Windows initialization is also **tiered**, with each tier representing a
separate responsibility:

- OS foundation
- Core tooling
- Personal preferences
- Experimental or optional changes

Each tier is:
- A standalone script
- Run manually
- Logged independently
- Separated by explicit reboot boundaries

Windows favors **explicit sequencing** over pretending reboots do not exist.

---

### Shared Philosophy

Across both platforms:

- Tiers are not re-entered implicitly
- Reboots are treated as hard boundaries
- Scripts do not attempt to resume after restart
- State is never smuggled through the filesystem or registry

If a tier must be re-run, it is done deliberately.

---

## What This Is *Not*

- A configuration management system
- A dotfile framework
- An enterprise imaging solution
- A zero-touch installer
- A cross-user abstraction layer

This repo optimizes for:
> *clarity, control, and future maintainability*  
not automation for its own sake.

---

## Repository Structure (High-Level)

```text
init/
├── linux/        # Linux bootstrap scripts and platform-specific config
├── windows/      # Windows tiered initialization scripts
├── dotfiles/     # Version-controlled configuration files (shared + per-OS)
└── README.md     # Repository overview
