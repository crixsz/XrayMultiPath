# XrayMultiPath with CF-Warp route and Direct route
This script will install Xray Core, Nginx, Docker(with warp container). It will have these default client configs


VLESS-WS Port 80 (CF Warp)
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
trojan://trojanaku@yourip:443?security=&type=ws&path=/trojan-ws&host=yourip#
```

TROJAN-WS Port 80 (Direct)
```
trojan://trojanaku@yourip:80?security=&type=ws&path=/direct-trojan&host=yourip#
```

VLESS-WS Port 80 (Direct)
```
vless://5d871382-b2ec-4d82-b5b8-712498a348e5@yourip:80?security=&type=ws&path=/direct-vless&host=yourip&encryption=none
```


# Installation Link
```
wget https://raw.githubusercontent.com/crixsz/XrayMultiPath/dual-xray/setup.sh && chmod +x setup.sh && bash setup.sh
```