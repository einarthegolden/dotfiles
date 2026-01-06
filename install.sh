#!/usr/bin/env bash
set -euo pipefail

### CONFIG ###
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO_ROOT/.config"
CONFIG_DST="$HOME/.config"
APPS_SRC="$REPO_ROOT/applications/pwa"
APPS_DST="$HOME/.local/share/applications"

echo "==> Starting dotfiles install"
echo "Repo: $REPO_ROOT"

### 1) Sanity checks ###
command -v pacman >/dev/null || {
  echo "pacman not found. This script is for Arch/CachyOS."
  exit 1
}

if [[ ! -d "$CONFIG_SRC" ]]; then
  echo "No .config directory in repo. Aborting."
  exit 1
fi

### 2) Install pacman packages ###
if [[ -f "$REPO_ROOT/pkglist.txt" ]]; then
  echo "==> Installing pacman packages"
  sudo pacman -S --needed --noconfirm - < "$REPO_ROOT/pkglist.txt"
else
  echo "==> No pkglist.txt found, skipping pacman packages"
fi

### 3) Install AUR packages ###
if [[ -f "$REPO_ROOT/pkglist_aur.txt" ]]; then
  if command -v yay >/dev/null; then
    echo "==> Installing AUR packages with yay"
    yay -S --needed --noconfirm - < "$REPO_ROOT/pkglist_aur.txt"
  elif command -v paru >/dev/null; then
    echo "==> Installing AUR packages with paru"
    paru -S --needed --noconfirm - < "$REPO_ROOT/pkglist_aur.txt"
  else
    echo "No AUR helper found (yay/paru). Skipping AUR packages."
  fi
fi

### 4) Apply dotfiles (overlay copy) ###
echo "==> Applying dotfiles"

mkdir -p "$CONFIG_DST"

for dir in "$CONFIG_SRC"/*; do
  name="$(basename "$dir")"
  echo "  -> $name"
  mkdir -p "$CONFIG_DST/$name"
  rsync -a --delete "$dir/" "$CONFIG_DST/$name/"
done

### 5) Restore PWAs ###
if [[ -d "$APPS_SRC" ]]; then
  echo "==> Restoring PWA desktop files"
  mkdir -p "$APPS_DST"
  rsync -a "$APPS_SRC/" "$APPS_DST/"
fi

### 6) Fix permissions for scripts ###
if [[ -d "$CONFIG_DST/hypr/scripts" ]]; then
  echo "==> Ensuring Hypr scripts are executable"
  chmod +x "$CONFIG_DST/hypr/scripts/"*.sh 2>/dev/null || true
fi

echo "==> Install complete"
echo "You may want to log out and back in."
