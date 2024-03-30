#!/bin/bash

# Function to start Xray processes
function start_xray() {
  screen -dmS xray_primary bash -c "xray run -config /usr/local/etc/xray/config.json"
  screen -dmS xray_none bash -c "xray run -config /usr/local/etc/xray/none.json"
  systemctl restart nginx
  echo "Xray processes started."
}

# Function to kill Xray processes
function kill_xray() {
  pkill xray
  systemctl stop nginx
  echo "Xray processes killed."
}

# Get user input
clear
echo -e "[Xray+Nginx controller]" 
echo -e "================="
echo -e "Status:"
if pgrep xray >/dev/null; then
    echo "[RUNNING]"
else
    echo "[NOT RUNNING]"
fi
echo ""
echo -e "1) Start"
echo -e "2) Stop"
echo -e "3) Restart"
echo ""
read -p "Select an option [1-3]: " action

echo ""

# Check user input and call appropriate function
case "$action" in
  1)
    start_xray
    ;;
  2)
    kill_xray
    ;;
  3)
    kill_xray
    sleep 2
    start_xray
    ;;
  *)
    echo "Invalid choice. Please enter '1' or '2'."
    ;;
esac

