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

```



## Installation (NEW MACHINE)
  
Prerequisites:

1 - Install CachyOS (Select Hyprland during install)

2 - Install ML4W dotfiles using the official ML4W method, and log in once to ensure ML4W is working

3 - Apply this overlay:

```
git clone https://github.com/einarthegolden/dotfiles.git
cd dotfiles
./install-overlay.sh
```


## This script:

*Installs packages (pacman + AUR)

*Copies configs on top of existing ML4W configs

*Restores PWA launchers

*Creates backups before overwriting anything

Backups are stored in:

~/.dotfiles-backups/YYYYMMDD-HHMMSS/

## Re-running the installer

The installer is idempotent and safe to re-run:

./install-overlay.sh


If a file already exists, it is backed up before being overwritten.

Important safety notes

⚠️ Do NOT use scripts that mirror or delete ~/.config

⚠️ This repo intentionally avoids rsync --delete

⚠️ ML4W internals (.mydotfiles/) are never tracked here

This design prevents accidental loss of upstream configuration.

## Philosophy:

This setup follows a strict layering model:

CachyOS + Hyprland        → OS + compositor
ML4W dotfiles             → base desktop framework
This repository           → personal overlay


Each layer is replaceable without breaking the others.

## Troubleshooting

If something looks wrong:

1 - Restore from ~/.dotfiles-backups

2 - Re-run the ML4W installer

3 - Re-apply this overlay

Nothing in this repo should make recovery difficult.

## License

Personal dotfiles. Use freely, but no guarantees.

pkglist.txt              # Pacman packages (userland only)
pkglist_aur.txt          # AUR packages (userland only)

install-overlay.sh       # SAFE installer (no deletes, backups enabled)
