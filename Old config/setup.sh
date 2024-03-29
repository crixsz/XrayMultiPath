#/bin/bash
#Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'

rm -rf /usr/local/etc/xray/config.json
clear
echo -e "${ORANGE} ===================================="
echo -e "${ORANGE}       Multi path Xray install       "
echo -e "${ORANGE} ===================================="
echo -e "${GREEN}Starting the Xray setup script..."
echo -e "${GREEN}Installing the setup packages..."
echo -e "${GREEN}Checking for initial setup..."
XRAY=/etc/systemd/system/xray.service
if [ -f "$XRAY" ]
then
  echo -e "${LIGHT}!!ERROR!! Xray has been installed !!"
	echo ""
	echo -e "${RED}Uninstalling Xray...."
	sleep 3
	systemctl disable xray
	rm -rf /usr/local/etc/xray
	rm -rf /etc/systemd/system/xray.service
	rm -rf /etc/systemd/system/xray.service.d
	rm -rf /etc/systemd/system/xray@.service
	rm -rf /etc/systemd/system/xray@.service.d
	rm -rf /etc/systemd/system/multi-user.target.wants/xray.service
	rm -rf /etc/systemd/system/xray.service.d/10-donot_touch_single_conf.conf
	rm -rf /etc/systemd/system/xray@.service.d/10-donot_touch_single_conf.conf
	rm -rf /root/xray.crt
	rm -rf /root/xray.key
	rm -rf /usr/local/bin/xray
	rm -rf /usr/local/etc/xray
	rm -rf /usr/local/etc/xray/config.json
	rm -rf usr/local/share/xray
	rm -rf /usr/local/share/xray/geoip.dat
	rm -rf usr/local/share/xray/geosite.dat
	rm -rf /var/log/xray
	rm -rf /var/log/xray/access.log
	rm -rf /var/log/xray/error.log
  systemctl daemon-reload
	clear
	echo -e "${RED}Uninstalled Xray!"
  ./setup
else
  apt-get update -y >> /dev/null
  apt-get install -y net-tools >> /dev/null
  apt-get install -y curl >> /dev/null
  apt-get install -y neofetch >> /dev/null
  apt-get install -y mlocate >> /dev/null
  apt-get install -y ncdu >> /dev/null
  apt-get install -y socat >> /dev/null
  apt-get install -y ca-certificates >> /dev/null
  apt-get install -y vnstat >> /dev/null
  clear
  echo -e "${GREEN}Configuring profile for alias PORTS..."
  sleep 3
  echo "alias ports='netstat -tulpn | grep LISTEN'" >> .profile
  service vnstat restart
  clear
  source .profile
  echo -e "Do you want to install Multipath Xray(y/n)?"
  echo ""
  read ans
  if [ $ans == "y" ]; 
  then
      echo -e "Enter your domain name(Ex:something.com)?"
      echo -n "Domain name: "
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
      echo -e "${GREEN}Installing Xray.."
      sleep 5
      clear
      bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root
      rm -rf /usr/local/etc/xray/config.json
      wget https://raw.githubusercontent.com/crixsz/XrayMultiPath/main/config.json && mv config.json /usr/local/etc/xray/
      systemctl restart xray
      clear
  else
      echo -e "${RED}Installation has been cancelled!!"
      sleep 3
      clear
  fi
