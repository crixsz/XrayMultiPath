"""### Functions
export ip=$(curl -s ipv4.icanhazip.com || curl -s ifconfig.me)
export scr_dir=$(pwd)

prequisites()
{
  clear
  apt install curl -y
  apt install socat -y
  apt install screen -y
  apt install net-tools -y
  apt install htop -y
}
acme_install(){
  clear
  if [ -f /root/xray.crt ] && [ -f /root/xray.key ]; then
    echo "Cert files already exist, proceeding to Xray installation..."
    sleep 3
    setup_nginx
    setup_cf_warp
    exit 0
  else
    echo "Cert files not found, generating new cert..."
    sleep 3
    clear
  fi
  echo "[Acme.sh Installation Script]"
  echo -n "Enter your domain name (Ex:something.com): "
  read domain
  clear
  echo -e "Generating cert for Xray...."
  echo -e "Installing Acme.sh..."
  sleep 3
  clear
  if [ -d /root/.acme.sh ]; then
    echo "Removing existing .acme.sh directory..."
    rm -rf /root/.acme.sh
  fi
  wget -O acme.sh https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh
  bash acme.sh --install
  rm acme.sh
  cd "$scr_dir/.acme.sh"
  bash acme.sh --register-account -m mymail@gmail.com
  bash acme.sh --issue --standalone -d $domain --force
  if [ $? -ne 0 ]; then
    echo "Acme.sh unable to generate cert please try to check if your domain is correct, exiting..."
    exit 0
  else
    bash acme.sh --installcert -d $domain --fullchainpath /root/xray.crt --keypath /root/xray.key
    if [ $? -ne 0 ]; then
      echo "Acme.sh unable to install cert please try to check if your domain is correct, exiting..."
      exit 0
    fi
  fi
  clear
  if [ -f /root/xray.crt ] && [ -f /root/xray.key ]; then
    echo "Cert generated successfully !!"
    sleep 3
  else
    echo "Cert generation failed !!"
    sleep 3
    exit 0
  fi
}""
setup_nginx(){
  clear
  echo "[Nginx Installation Script]"
  echo -e "Installing Nginx..."
  sleep 3
  apt-get install nginx -y
  clear
  #setup nginx config for xray (nginx.conf and xray.conf)
  echo -e "Configuring Nginx for Xray..."
  rm -rf /etc/nginx/nginx.conf
  sleep 2
  wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/crixsz/XrayMultiPath/dual-xray/Nginx/nginx.conf
  wget -O /etc/nginx/conf.d/xray.conf https://raw.githubusercontent.com/crixsz/XrayMultiPath/dual-xray/Nginx/xray.conf
  systemctl restart nginx
  nginx_status=$(systemctl is-active nginx)
  if [ "$nginx_status" == "active" ]; then
    echo "Configured successfully"
    sleep 2
  else
    echo "Nginx is not running."
    sleep 3
    exit 0
  fi
}
setup_cf_warp(){
  clear
  echo "[Docker Setup]"
  wget https://raw.githubusercontent.com/crixsz/DockerInstall/main/docker-install.sh && chmod +x docker-install.sh && ./docker-install.sh
  clear
  sleep 2
  echo "[CF Warp Setup]"
  ## moving to https://github.com/aleskxyz/warp-svc
  docker run --restart always -d --name=warp -e FAMILIES_MODE=off -p 127.0.0.1:1080:1080 -v /usr/local/warp:/var/lib/cloudflare-warp ghcr.io/aleskxyz/warp-svc:latest
  docker ps
  sleep 5
  ## bash <(curl -fsSL git.io/warp.sh) install (warp-cli currently causes SSH to disconnect)
  ## bash <(curl -fsSL git.io/warp.sh) proxy (warp-cli currently causes SSH to disconnect)
  sleep 2
  clear
  ## bash <(curl -fsSL git.io/warp.sh) status (warp-cli currently causes SSH to disconnect)
  echo "[Moving to Xray Installation]"
  install_xray
}
install_xray() {
  # check if already exist
  if [ -f /usr/local/bin/xray ]; then
    echo "Xray Core is already installed !!"
    read -p "Do you want to uninstall currently installed Xray Core? [y/n]: " uninstall_option
    if [ "$uninstall_option" == "y" ]; then
      echo "Uninstalling currently installed Xray Core..."
      uninstall_xray
      exit 0
    else
      echo "Exiting..."
      sleep 3
      clear
      exit 0
    fi
  fi
  echo "[Xray Core Installation Script]"
  echo "Starting installation of xray core v1.5.0.."
  sleep 3
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version 1.5.0 -u root
  sleep 2 
  clear
  echo "Xray Core installed successfully !!"
  sleep 2
  clear 
  #wget https://raw.githubusercontent.com/crixsz/XrayMultiPath/main/Xray/xraymulticontroller.sh && mv xraymulticontroller.sh /usr/local/bin/xraymulticontroller && chmod +x /usr/local/bin/xraymulticontroller
  wget https://raw.githubusercontent.com/crixsz/XrayMultiPath/dual-xray/Xray/config.json && mv config.json /usr/local/etc/xray/
  wget https://raw.githubusercontent.com/crixsz/XrayMultiPath/dual-xray/Xray/none.json && mv none.json /usr/local/etc/xray/
  wget https://raw.githubusercontent.com/crixsz/XrayMultiPath/dual-xray/Xray/direct.json && mv direct.json /usr/local/etc/xray/
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
  rm -rf /etc/systemd/system/xray@.service
  wget -O /etc/systemd/system/xray@.service https://raw.githubusercontent.com/crixsz/XrayMultiPath/dual-xray/Xray/xray@.service
  systemctl daemon-reload
  systemctl start xray@none
  systemctl start xray
  systemctl start xray@direct
  systemctl enable xray@none
  systemctl enable xray
  systemctl enable xray@direct
  clear
  sleep 2
  echo "Xray Core installed successfully !!"
  echo ""
  echo -e "\033[0;32m[ VLESS-WS Port 80 (CF Warp) ]\033[0m"
  echo "vless://5d871382-b2ec-4d82-b5b8-712498a348e5@${ip}:80?security=&type=ws&path=/vless-ws&host=${ip}&encryption=none"
  echo ""
  echo -e "\033[0;32m[ VLESS-WS Port 443 (CF Warp) ]\033[0m"
  echo "vless://5d871382-b2ec-4d82-b5b8-712498a348e5@${ip}:443?security=tls&sni=bug.com&allowInsecure=1&type=ws&path=/vless-ws&encryption=none"
  echo ""  
  echo -e "\033[0;32m[ TROJAN-WS Port 80 (CF Warp) ]\033[0m"
  echo "trojan://trojanaku@${ip}:80?security=&type=ws&path=/trojan-ws&host=${ip}#"
  echo ""
  echo -e "\033[0;32m[ TROJAN-WS Port 443 (CF Warp) ]\033[0m"
  echo "trojan://trojankau@${ip}:443?security=&type=ws&path=/trojan-ws&host=${ip}#"
  echo ""
  echo -e "\033[0;32m[ TROJAN-WS Port 80 (Direct) ]\033[0m"
  echo "trojan://trojanaku@${ip}:80?security=&type=ws&path=/direct&host=${ip}#"
  echo ""
  echo -e "\033[0;32m[ VLESS-WS Port 80 (Direct) ]\033[0m"
  echo "vless://5d871382-b2ec-4d82-b5b8-712498a348e5@${ip}:80?security=&type=ws&path=/direct-vless&host=${ip}&encryption=none"
  echo ""
}

uninstall_xray(){
  systemctl stop xray
  systemctl stop xray@none
  systemctl stop xray@direct
  systemctl disable xray
  systemctl disable xray@none
  systemctl disable xray@direct
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge  
  apt-get purge nginx nginx-common -y
  # remove docker and all its container 
  docker rm -f $(docker ps -a -q)
  docker rmi -f $(docker images -a -q)
  docker system prune -a -f
  systemctl reset-failed
  systemctl daemon-reload
  rm -rf /usr/local/etc/xray
  rm -rf /etc/systemd/system/xray.service
  rm -rf /etc/systemd/system/xray@.service
  rm -rf /etc/systemd/system/xray@.service.d
  rm -rf /etc/systemd/system/xray.service.d
  rm -rf /root/docker-install.sh
  rm -rf /usr/local/bin/xray
  rm -rf 
  clear 
  echo "Xray Core uninstalled successfully !!"
  sleep 3

}
## Main output
clear
echo -e "\033[0;34m[ Xray Dual Config Multipath + CF Warp Installation Script ]\033[0m"
echo ""
echo "1) Install Xray Core (Dual config) + Acme.sh + Nginx + CF Warp"
echo "2) Uninstall Xray Core (Dual config) + Acme.sh + Nginx + CF Warp"
echo "3) Exit"
echo ""
read -p "Select an option [1-3]: " option

case $option in
  1)
    prequisites
    acme_install
    setup_nginx
    setup_cf_warp
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

