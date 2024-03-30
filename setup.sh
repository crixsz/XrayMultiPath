### Functions
prequisites()
{
  clear
  apt install curl -y
  apt install socat -y
  apt install screen -y
  apt install net-tools -y
  apt install htop -y
}

setup_nginx(){
  clear
  echo "[Nginx Installation Script]"
  echo -e "Installing Nginx..."
  apt-get install nginx -y
  clear
  #setup nginx config for xray (nginx.conf and xray.conf)
  echo -e "Configuring Nginx for Xray..."
  rm -rf /etc/nginx/nginx.conf
  sleep 2
  wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/crixsz/XrayMultiPath/main/Nginx/nginx.conf
  wget -O /etc/nginx/conf.d/xray.conf https://raw.githubusercontent.com/crixsz/XrayMultiPath/main/Nginx/xray.conf
  systemctl restart nginx
  nginx_status=$(systemctl is-active nginx)
  if [ "$nginx_status" == "active" ]; then
    echo "Configured successfully"
    sleep 2
  else
    echo "Nginx is not running."
    exit 0
  fi
}
acme_install(){
  clear
  if [ -f /root/xray.crt ] && [ -f /root/xray.key ]; then
    echo "Cert files already exist, proceeding to Xray installation..."
    sleep 3
    setup_nginx
    install_xray
  else
    echo "Cert files not found, generating new cert..."
  fi
  echo "[Acme.sh Installation Script]"
  echo -n "Enter your domain name (Ex:something.com): "
  read domain
  clear
  echo -e "Generating cert for Xray...."
  wget -O acme.sh https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh
  bash acme.sh --install
  rm acme.sh
  cd .acme.sh
  bash acme.sh --register-account -m mymail@gmail.com
  bash acme.sh --issue --standalone -d $domain --force
  bash acme.sh --installcert -d $domain --fullchainpath /root/xray.crt --keypath /root/xray.key
  clear
  if [ -f /root/xray.crt ] && [ -f /root/xray.key ]; then
    echo "Cert generated successfully !!"
  else
    echo "Cert generation failed !!"
    exit 0
  fi
}
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
  sleep 2
  clear 
  #wget https://raw.githubusercontent.com/crixsz/XrayMultiPath/main/Xray/xraymulticontroller.sh && mv xraymulticontroller.sh /usr/local/bin/xraymulticontroller && chmod +x /usr/local/bin/xraymulticontroller
  wget https://raw.githubusercontent.com/crixsz/XrayMultiPath/main/Xray/config.json && mv config.json /usr/local/etc/xray/
  wget https://raw.githubusercontent.com/crixsz/XrayMultiPath/main/Xray/none.json && mv none.json /usr/local/etc/xray/
  if [ -f /usr/local/etc/xray/config.json ] && [ -f /usr/local/etc/xray/none.json ]; then
    echo "Successfully configured Xray config"
  else
    echo "Xray config file download failed !!"
    exit 0
  fi
  clear
  systemctl stop xray
  if pgrep xray >/dev/null; then
    echo "Xray is still running. Exiting..."
    exit 0
  fi
  rm -rf /etc/systemd/system/xray.service
  wget -O /etc/systemd/system/xray.service https://raw.githubusercontent.com/crixsz/XrayMultiPath/main/Xray/xray.service
  systemctl daemon-reload
  systemctl restart xray
  clear
  sleep 2
  #xraymulticontroller
}

uninstall_xray(){
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge  
  sudo apt-get purge nginx nginx-common
  rm -rf /etc/nginx
  rm -rf /usr/local/etc/xray
  rm -rf /etc/systemd/system/xray.service
  rm -rf /etc/systemd/system/xray@.service
  rm -rf /usr/local/bin/xraymulticontroller
  clear 
  echo "Xray Core uninstalled successfully !!"

}
## Main output
clear
echo "[ Xray Multipath Installation Script ]"
echo "1) Install Xray Core + Acme.sh + Nginx"
echo "2) Uninstall Xray Core + Acme.sh + Nginx"
echo "3) Exit"
echo ""
read -p "Select an option [1-3]: " option

case $option in
  1)
    prequisites
    acme_install
    setup_nginx
    install_xray
    ;;
  2)
    echo "Uninstalling All related files..."
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