#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_SRC="$REPO_ROOT/.config"
CONFIG_DST="$HOME/.config"

PWA_SRC="$REPO_ROOT/applications/pwa"
PWA_DST="$HOME/.local/share/applications"

PKG_PACMAN="$REPO_ROOT/pkglist.txt"
PKG_AUR="$REPO_ROOT/pkglist_aur.txt"

BACKUP_ROOT="$HOME/.dotfiles-backups"
BACKUP_DIR="$BACKUP_ROOT/$(date +'%Y%m%d-%H%M%S')"

have() { command -v "$1" >/dev/null 2>&1; }

log() { printf "\n==> %s\n" "$*"; }

die() { printf "\nERROR: %s\n" "$*" >&2; exit 1; }

backup_if_exists() {
  # backup_if_exists <absolute_target_path>
  local target="$1"
  if [[ -e "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    # Preserve parents so restore is easy
    local rel="${target#$HOME/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    cp -a "$target" "$BACKUP_DIR/$rel"
  fi
}

sync_overlay_dir() {
  # sync_overlay_dir <src_dir> <dst_dir>
  local src="$1"
  local dst="$2"

  [[ -d "$src" ]] || return 0
  mkdir -p "$dst"

  # For every file in src, back up the destination if it exists,
  # then copy over (merge overlay). NO deletion.
  while IFS= read -r -d '' f; do
    local rel="${f#$src/}"
    local target="$dst/$rel"
    mkdir -p "$(dirname "$target")"
    backup_if_exists "$target"
    cp -a "$f" "$target"
  done < <(find "$src" -type f -print0)
}

log "Overlay installer (SAFE: no deletes)"
log "Repo: $REPO_ROOT"

# ---- 0) Basic checks ----
have pacman || die "pacman not found. This is for Arch/CachyOS."
mkdir -p "$CONFIG_DST" "$PWA_DST"

# ---- 1) Packages (pacman) ----
if [[ -f "$PKG_PACMAN" ]]; then
  log "Installing pacman packages (no removals)"
  # Filter blanks/comments
  PAC_PKGS="$(grep -vE '^\s*($|#)' "$PKG_PACMAN" || true)"
  if [[ -n "${PAC_PKGS:-}" ]]; then
    # shellcheck disable=SC2086
    sudo pacman -S --needed --noconfirm $PAC_PKGS
  else
    echo "No pacman packages listed (after filtering)."
  fi
else
  log "No pkglist.txt found; skipping pacman packages"
fi

# ---- 2) Packages (AUR) ----
if [[ -f "$PKG_AUR" ]]; then
  log "Installing AUR packages (no removals)"
  AUR_HELPER=""
  if have yay; then AUR_HELPER="yay"; fi
  if have paru; then AUR_HELPER="${AUR_HELPER:-paru}"; fi

  AUR_PKGS="$(grep -vE '^\s*($|#)' "$PKG_AUR" || true)"
  if [[ -z "${AUR_PKGS:-}" ]]; then
    echo "No AUR packages listed (after filtering)."
  elif [[ -z "$AUR_HELPER" ]]; then
    echo "No AUR helper (yay/paru) found; skipping AUR packages."
  else
    # shellcheck disable=SC2086
    "$AUR_HELPER" -S --needed --noconfirm $AUR_PKGS
  fi
else
  log "No pkglist_aur.txt found; skipping AUR packages"
fi

# ---- 3) Apply dotfiles overlay (NO deletes; backups on overwrite) ----
log "Applying dotfiles overlay into ~/.config (backups enabled)"
if [[ -d "$CONFIG_SRC" ]]; then
  sync_overlay_dir "$CONFIG_SRC" "$CONFIG_DST"
else
  log "No .config directory in repo; skipping dotfiles"
fi

# ---- 4) Restore PWA .desktop files (NO deletes; backups on overwrite) ----
log "Restoring PWA desktop launchers"
if [[ -d "$PWA_SRC" ]]; then
  sync_overlay_dir "$PWA_SRC" "$PWA_DST"
else
  echo "No applications/pwa directory in repo; skipping PWA restore."
fi

# ---- 5) Ensure scripts executable (non-fatal) ----
log "Fixing script permissions (best-effort)"
chmod +x "$HOME/.config/hypr/scripts/"*.sh 2>/dev/null || true

log "Done."
if [[ -d "$BACKUP_DIR" ]]; then
  echo "Backups created at: $BACKUP_DIR"
else
  echo "No backups were necessary."
fi
echo "Tip: log out/in or reload Hyprland config if needed."
