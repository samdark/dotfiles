#!/bin/bash
# Save current TTY state
exec < /dev/tty > /dev/tty 2>&1

# Completely suspend MC and take over terminal
kill -STOP $PPID

# Clear and show image
clear
wezterm imgcat "$1"
echo ""
read -n1 -p "Press any key to continue..."

# Resume MC
clear
kill -CONT $PPID