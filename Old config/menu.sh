#!/bin/bash

# Define the colors
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color - to reset the color

draw_line() {
  echo -e "${RED}-------------------------------------${NC}"
}

# Function to draw a header line with title centered
draw_header() {
  text="$1"
  # Get the width of the terminal
  width=$(tput cols)
  # Calculate the text padding for centering
  echo -e "${RED}$text${NC}"
  draw_line
}


# Function to draw menu entry
draw_menu_entry() {
  local num="$1"
  local desc="$2"
  printf "${ORANGE}[%d] ${NC}%s\n" "$num" "$desc"
}

# Clear the screen
clear

# Draw the header
draw_line
draw_header "XRAY MULTIPORT MENU"

# Server info
echo -e "${GREEN}INFO SERVER${NC}"
echo "System Uptime   : $(uptime -p)"
echo "Memory Usage    : $(free -m | awk '/Mem:/ {print $3 "MB / " $2 "MB (" $3/$2*100 "%)"}')"
echo "CPU Load        : $(top -bn1 | grep load | awk '{printf "%.2f%%", $(NF-2)}')"
echo "Timezone        : $(timedatectl | grep 'Time zone' | awk '{print $3}')"
echo "IP Address      : $(hostname -I | cut -d' ' -f1)"

# Service status
echo ""
echo -e "${GREEN}---- [ Service status] ----${NC}"
echo -e "${GREEN}XRAY-CORE: ON | NGINX: ON${NC}"

# Draw the XRAY menu
echo ""
draw_line
draw_header "XRAY MENU"
draw_menu_entry 1 "XRAY Vmess WS Panel"
draw_menu_entry 2 "XRAY Vless WS Panel"
draw_menu_entry 3 "XRAY Trojan WS Panel"
draw_menu_entry 4 "XRAY Vless TCP XTLS Panel"
draw_menu_entry 5 "XRAY Trojan TCP Panel"


# Reset the color
echo -e "${NC}"
