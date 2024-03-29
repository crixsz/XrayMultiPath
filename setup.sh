clear
echo "[ Xray Core Installation Script ]"
echo "1) Install Xray Core + Acme.sh + Nginx"
echo "2) Uninstall Xray Core + Acme.sh + Nginx"
echo "3) Exit"
echo ""
read -p "Select an option [1-3]: " option

case $option in
  1)
    install_xray
    ;;
  2)
    echo "Uninstalling Xray Core..."
    uninstall_xray
    ;;
  3)
    echo "Exiting..."
    exit 0
    ;;
  *)
    echo "Invalid option. Please select a valid option."
    ;;
esac

install_xray() {
  # check if already exist
  if [ -f /usr/local/bin/xray ]; then
    echo "Xray Core is already installed !!"
    read -p "Do you want to uninstall currently installed Xray Core? [y/n]: " uninstall_option
    if [ "$uninstall_option" == "y" ]; then
      echo "Uninstalling currently installed Xray Core..."
      uninstall_xray
    else
      echo "Exiting..."
      sleep 3
      clear
      exit 0
    fi
  fi
  echo "Starting installation of xray core v1.5.0.."
  sleep 3
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version 1.5.0 -u root
  sleep 2 
  clear
  echo "Xray Core installed successfully !!"
  echo "Starting installation of Acme.sh.."
  sleep 3
  
}

uninstall_xray(){
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge  
  clear 
  echo "Xray Core uninstalled successfully !!"
}