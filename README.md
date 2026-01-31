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

Linux initialization is handled by a **single bootstrap script** designed to work across:

- Desktop systems
- VPS / virtualized hosts
- Cloud-init environments

Key characteristics:

- Idempotent (safe to re-run)
- Non-interactive
- Dry-run capable
- Environment-aware (desktop vs server)
- Explicit SSH hardening and validation

Linux favors **declarative convergence** where possible.

---

### 🪟 Windows

Windows initialization is intentionally **phase-based**, not monolithic.

Setup is split into **tiers**, each representing a distinct responsibility:

- OS foundation
- Core tooling
- Personal preferences
- Experimental changes

Each tier is:
- A standalone script
- Run manually
- Logged independently
- Separated by explicit reboot boundaries

Windows favors **explicit sequencing** over pretending reboots don’t exist.

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
├── linux/      # Linux tiered initialization scripts
├── windows/    # Windows tiered initialization scripts
└── README.md   # This file
