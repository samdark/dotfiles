#!/bin/bash
# Image viewer script for use with Midnight Commander
# Displays images and allows navigation with arrow keys

# Save current TTY state
exec < /dev/tty > /dev/tty 2>&1

# Completely suspend MC and take over terminal
kill -STOP $PPID

# Get the directory and current file
CURRENT_FILE="$1"
DIR=$(dirname "$CURRENT_FILE")
BASENAME=$(basename "$CURRENT_FILE")

# Get list of image files in the directory
mapfile -t IMAGES < <(find "$DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.bmp" \) | sort)

# Find current image index
CURRENT_INDEX=0
for i in "${!IMAGES[@]}"; do
    if [[ "${IMAGES[$i]}" == "$CURRENT_FILE" ]]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Function to display image
show_image() {
    clear
    wezterm imgcat "$1"
    echo ""
    echo "Image: $(basename "$1") ($(($2 + 1))/${#IMAGES[@]})"
    echo "← Previous | → Next | Home: First | End: Last | ESC: Quit"
}

# Display initial image
NEEDS_REDRAW=true

# Main loop
while true; do
    # Only redraw if needed
    if [[ $NEEDS_REDRAW == true ]]; then
        show_image "${IMAGES[$CURRENT_INDEX]}" "$CURRENT_INDEX"
        NEEDS_REDRAW=false
    fi
    
    # Read key input (handles arrow keys and escape sequences)
    read -rsn1 key
    
    # Check for ESC or special keys
    if [[ $key == $'\e' ]]; then
        # Read next characters to check for arrow keys or other escape sequences
        read -rsn1 -t 0.1 key2
        
        if [[ $key2 == "" ]]; then
            # Pure ESC key pressed (no following characters) = quit
            break
        elif [[ $key2 == "[" ]]; then
            # Escape sequence - read one more character
            read -rsn1 -t 0.1 key3
            
            case $key3 in
                D)  # Left arrow - previous image
                    if [[ $CURRENT_INDEX -gt 0 ]]; then
                        ((CURRENT_INDEX--))
                        NEEDS_REDRAW=true
                    fi
                    ;;
                C)  # Right arrow - next image
                    if [[ $CURRENT_INDEX -lt $((${#IMAGES[@]} - 1)) ]]; then
                        ((CURRENT_INDEX++))
                        NEEDS_REDRAW=true
                    fi
                    ;;
                H)  # Home key - first image
                    if [[ $CURRENT_INDEX -ne 0 ]]; then
                        CURRENT_INDEX=0
                        NEEDS_REDRAW=true
                    fi
                    ;;
                F)  # End key - last image
                    if [[ $CURRENT_INDEX -ne $((${#IMAGES[@]} - 1)) ]]; then
                        CURRENT_INDEX=$((${#IMAGES[@]} - 1))
                        NEEDS_REDRAW=true
                    fi
                    ;;
                1)  # Extended key sequence (Home on some terminals)
                    read -rsn1 -t 0.1 key4
                    if [[ $key4 == "~" ]] && [[ $CURRENT_INDEX -ne 0 ]]; then
                        CURRENT_INDEX=0
                        NEEDS_REDRAW=true
                    fi
                    ;;
                4)  # Extended key sequence (End on some terminals)
                    read -rsn1 -t 0.1 key4
                    if [[ $key4 == "~" ]] && [[ $CURRENT_INDEX -ne $((${#IMAGES[@]} - 1)) ]]; then
                        CURRENT_INDEX=$((${#IMAGES[@]} - 1))
                        NEEDS_REDRAW=true
                    fi
                    ;;
            esac
        fi
    else
        # Any other key: next image (but stop at last)
        if [[ $CURRENT_INDEX -lt $((${#IMAGES[@]} - 1)) ]]; then
            ((CURRENT_INDEX++))
            NEEDS_REDRAW=true
        fi
    fi
done

# Resume MC
clear
kill -CONT $PPID