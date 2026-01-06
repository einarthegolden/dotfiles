# Dotfiles – CachyOS + Hyprland (ML4W Overlay)

This repository contains **my personal configuration overlay** for a
CachyOS + Hyprland desktop using the **ML4W dotfiles** as the base.

⚠️ **Important concept**  
This repo is **NOT a full dotfiles mirror**.  
It is an **overlay** that is meant to be applied *on top of* ML4W.

Nothing here should replace or delete upstream ML4W configuration.

---

## What this repo is

- A **personal overlay layer** for:
  - Hyprland (keybindings, window rules, scripts)
  - Kitty
  - Waybar / Rofi / Btop (if present)
  - Custom scripts
  - Chromium PWAs (`.desktop` launchers)
- A **portable setup** I can apply to:
  - new laptops
  - future desktops
  - test machines
- A way to reproduce *my* workflow without freezing ML4W internals

---

## What this repo is NOT

- ❌ Not a replacement for ML4W
- ❌ Not a full copy of `~/.config`
- ❌ Not a system installer
- ❌ Not hardware-aware (no drivers, kernels, firmware)

---

## Repository structure

```text
.config/                 # Overlay configs only (merged on top)
  hypr/
    conf/
      keybindings/
        einarthegolden.conf
      windows/
        einarthegolden.conf
      window.conf
    scripts/
      workspace_scene.sh

applications/
  pwa/                   # Chromium PWA launchers (.desktop files)

pkglist.txt              # Pacman packages (userland only)
pkglist_aur.txt          # AUR packages (userland only)

install-overlay.sh       # SAFE installer (no deletes, backups enabled)
