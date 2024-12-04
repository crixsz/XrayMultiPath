# XrayMultiPath with CF-Warp as proxy (Bypass some DigitalOcean restriction)
This script will install xray-core and generate 3 protocol for default uuid which are TROJAN WS, VLESS WS, VMESS WS and TROJAN TCP. It will also include a CF Warp proxy for 
the Xray core to route to bypass the IP restrictions of some VPS 

```
vless://5d871382-b2ec-4d82-b5b8-712498a348e5@yourip:80?security=&type=ws&path=/vless-ws&host=yourip&encryption=none
```

VLESS-WS Port 443 (CF Warp)
```
vless://5d871382-b2ec-4d82-b5b8-712498a348e5@yourip:443?security=tls&sni=bug.com&allowInsecure=1&type=ws&path=/vless-ws&encryption=none
```

TROJAN-WS Port 80 (CF Warp)
```
trojan://trojanaku@yourip:80?security=&type=ws&path=/trojan-ws&host=yourip#
```

TROJAN-WS Port 443 (CF Warp)
```
trojan://trojankau@yourip:443?security=&type=ws&path=/trojan-ws&host=yourip#
```

TROJAN-WS Port 80 (Direct)
```
trojan://trojanaku@yourip:80?security=&type=ws&path=/direct&host=yourip#
```

# Installation Link
```
wget https://raw.githubusercontent.com/crixsz/XrayMultiPath/dual-xray/setup.sh && chmod +x setup.sh && bash setup.sh
```
