#!/usr/bin/env bash

wait_for() {
  until hyprctl clients | grep -q "$1"; do
    sleep 0.1
  done
}

############################
# Workspace 2 — Zen Browser
############################
zen-browser &
wait_for "class: zen"
hyprctl dispatch movetoworkspace 2,class:zen


############################
# Workspace 3 — 3 windows
#
# Layout:
# LEFT (master):
#   - btop (kitty -e btop)
#
# RIGHT stack (vertical):
#   - top: default terminal (fastfetch)
#   - bottom: Tauon
############################

# btop (master)
kitty --title btop -e btop &
wait_for "title: btop"
hyprctl dispatch movetoworkspace 3,title:btop

# default terminal
kitty --title term &
wait_for "title: term"
hyprctl dispatch movetoworkspace 3,title:term

# Tauon
tauon &
wait_for "class: tauonmb"
hyprctl dispatch movetoworkspace 3,class:tauonmb
hyprctl dispatch workspace 3
hyprctl dispatch focuswindow class:tauonmb
hyprctl dispatch fullscreenstate 0
hyprctl dispatch settiled

# Arrange WS3
hyprctl dispatch workspace 3

# Make btop the master (LEFT)
hyprctl dispatch focuswindow title:btop
hyprctl dispatch layoutmsg swapwithmaster

# Ensure terminal is TOP of right stack
hyprctl dispatch focuswindow title:term
hyprctl dispatch layoutmsg bringactivetotop

# Ensure Tauon is BOTTOM of right stack
hyprctl dispatch focuswindow class:tauonmb
hyprctl dispatch layoutmsg bringactivetotop


############################
# Workspace 4 — Discord | ChatGPT
#
# LEFT: Discord
# RIGHT: ChatGPT
############################

discord-screenaudio &
wait_for "class: de.shorsh.discord-screenaudio"
hyprctl dispatch movetoworkspace 4,class:de.shorsh.discord-screenaudio

gtk-launch chrome-cadlkienfkclaiaibeoongdcgmdikeeg-Default &
wait_for "class: chrome-cadlkienfkclaiaibeoongdcgmdikeeg-Default"
hyprctl dispatch movetoworkspace 4,class:chrome-cadlkienfkclaiaibeoongdcgmdikeeg-Default

# Arrange WS4
hyprctl dispatch workspace 4
hyprctl dispatch focuswindow class:de.shorsh.discord-screenaudio
hyprctl dispatch layoutmsg swapwithmaster

# Set split ratio: Discord 70% (master) / ChatGPT 30% (stack)
hyprctl dispatch layoutmsg mfact 0.70


############################
# Workspace 5 — WhatsApp | Notion
#
# LEFT: WhatsApp
# RIGHT: Notion
############################

gtk-launch chrome-hnpfjngllnobngcgfapefoaidbinmjnm-Default &
wait_for "class: chrome-hnpfjngllnobngcgfapefoaidbinmjnm-Default"
hyprctl dispatch movetoworkspace 5,class:chrome-hnpfjngllnobngcgfapefoaidbinmjnm-Default

gtk-launch chrome-ahhfekbghlghilfdnjplcegnokggeboe-Default &
wait_for "class: chrome-ahhfekbghlghilfdnjplcegnokggeboe-Default"
hyprctl dispatch movetoworkspace 5,class:chrome-ahhfekbghlghilfdnjplcegnokggeboe-Default

# Arrange WS5
hyprctl dispatch workspace 5
hyprctl dispatch focuswindow class:chrome-hnpfjngllnobngcgfapefoaidbinmjnm-Default
hyprctl dispatch layoutmsg swapwithmaster


############################
# Workspace 1 — Steam (LAUNCH LAST)
############################

# Go to WS1 first, then start Steam so the login/main windows naturally land there
hyprctl dispatch workspace 1
steam &

# Wait for any Steam window to appear, then force it to WS1
wait_for "class: steam"
hyprctl dispatch movetoworkspace 1,class:steam

# Final sweep: if Steam spawns a late window, force it back to WS1
hyprctl dispatch movetoworkspace 1,class:steam

# Stay on workspace 1
hyprctl dispatch workspace 1
