#!/usr/bin/env bash
set -u

# ---------- helpers ----------
need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }; }
need hyprctl
need jq

addr_by_class() {
  local klass="$1"
  hyprctl -j clients | jq -r --arg c "$klass" '.[] | select(.class==$c) | .address' | head -n1
}

addr_thorium_by_initialTitle() {
  local it="$1"
  hyprctl -j clients | jq -r --arg it "$it" '
    .[] | select(.class=="Thorium-browser" and (.initialTitle // "") == $it) | .address
  ' | head -n1
}

wait_addr() {
  # wait_addr <fn> <arg> [timeout_seconds]
  local fn="$1"
  local arg="$2"
  local timeout="${3:-15}"
  local tries=$((timeout * 10))
  local out=""

  for _ in $(seq 1 "$tries"); do
    out="$("$fn" "$arg" 2>/dev/null || true)"
    if [[ -n "${out:-}" && "$out" != "null" ]]; then
      echo "$out"
      return 0
    fi
    sleep 0.1
  done
  return 1
}

force_tiled_no_fullscreen_no_float() {
  local addr="$1"
  [[ -z "${addr:-}" ]] && return 0

  hyprctl dispatch focuswindow "address:${addr}" >/dev/null 2>&1 || true

  local fs floating
  fs="$(hyprctl -j clients | jq -r --arg a "$addr" '.[] | select(.address==$a) | .fullscreen' | head -n1)"
  floating="$(hyprctl -j clients | jq -r --arg a "$addr" '.[] | select(.address==$a) | .floating' | head -n1)"

  if [[ "${fs:-0}" != "0" ]]; then
    hyprctl dispatch fullscreen 0 >/dev/null 2>&1 || true
  fi
  if [[ "${floating:-false}" == "true" ]]; then
    hyprctl dispatch togglefloating >/dev/null 2>&1 || true
  fi

  hyprctl dispatch settiled >/dev/null 2>&1 || true
}

move_ws() {
  local addr="$1"
  local ws="$2"
  [[ -z "${addr:-}" ]] && return 0
  hyprctl dispatch movetoworkspacesilent "${ws},address:${addr}" >/dev/null 2>&1 || true
  force_tiled_no_fullscreen_no_float "$addr"
}

set_master_layout_for_ws() {
  local ws="$1"
  hyprctl dispatch workspace "$ws" >/dev/null 2>&1 || true
  # Ensure mfact/swapwithmaster behave as expected
  hyprctl dispatch layoutmsg setlayout master >/dev/null 2>&1 || true
}

# ---------- Workspace 1 — Floorp (alone) ----------
floorp &
FLOORP_ADDR="$(wait_addr addr_by_class "floorp" 10 || true)"
[[ -n "${FLOORP_ADDR:-}" ]] && move_ws "$FLOORP_ADDR" 1

# ---------- Workspace 2 — ChatGPT (LEFT) + Slack (RIGHT) ----------
gtk-launch chrome-cadlkienfkclaiaibeoongdcgmdikeeg-Default &
CHATGPT_ADDR="$(wait_addr addr_by_class "chrome-cadlkienfkclaiaibeoongdcgmdikeeg-Default" 15 || true)"
[[ -n "${CHATGPT_ADDR:-}" ]] && move_ws "$CHATGPT_ADDR" 2

# Launch all 3 Thorium PWAs (don’t guess which is which)
gtk-launch thorium-cifhbcnohmdccbgoicgdjpfamggdegmo-Default &
gtk-launch thorium-faolnafnngnfdaknnbpnkhgohbobgegn-Default &
gtk-launch thorium-lbllepbefcgndhjcogbgojikdiaaonfd-Default &

# Detect each by initialTitle (confirmed by you)
SLACK_ADDR="$(wait_addr addr_thorium_by_initialTitle "Slack" 25 || true)"
TEAMS_ADDR="$(wait_addr addr_thorium_by_initialTitle "Microsoft Teams (PWA)" 25 || true)"
OUTLOOK_ADDR="$(wait_addr addr_thorium_by_initialTitle "Outlook (PWA)" 25 || true)"

# Place them on the right workspaces
[[ -n "${SLACK_ADDR:-}" ]] && move_ws "$SLACK_ADDR" 2
[[ -n "${TEAMS_ADDR:-}" ]] && move_ws "$TEAMS_ADDR" 3
[[ -n "${OUTLOOK_ADDR:-}" ]] && move_ws "$OUTLOOK_ADDR" 3

# Arrange WS2 (master layout + ChatGPT as master + mfact)
set_master_layout_for_ws 2

# Make ChatGPT master (LEFT)
if [[ -n "${CHATGPT_ADDR:-}" ]]; then
  hyprctl dispatch focuswindow "address:${CHATGPT_ADDR}" >/dev/null 2>&1 || true
  hyprctl dispatch layoutmsg swapwithmaster >/dev/null 2>&1 || true
  # Split ratio: ChatGPT master 35% / Slack 65%
  hyprctl dispatch layoutmsg mfact 0.35 >/dev/null 2>&1 || true
fi

# ---------- Workspace 3 — Teams (LEFT) + Outlook (RIGHT) ----------
set_master_layout_for_ws 3

# Make Teams master (LEFT)
if [[ -n "${TEAMS_ADDR:-}" ]]; then
  hyprctl dispatch focuswindow "address:${TEAMS_ADDR}" >/dev/null 2>&1 || true
  hyprctl dispatch layoutmsg swapwithmaster >/dev/null 2>&1 || true
fi

# Finish on WS1
hyprctl dispatch workspace 1 >/dev/null 2>&1 || true
[[ -n "${FLOORP_ADDR:-}" ]] && hyprctl dispatch focuswindow "address:${FLOORP_ADDR}" >/dev/null 2>&1 || true
