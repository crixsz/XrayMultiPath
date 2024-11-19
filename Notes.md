## Notes about Xraycore (Dual CF Warp and Direct using different websocket path)

- Can create new config and new Nginx config to route different rule like CF Warp and Freedom

```nginx
    location = /vmess-ws {
        proxy_pass http://127.0.0.1:1211;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
    }

    location = /vless-ws {
        proxy_pass http://127.0.0.1:1212;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
    }

    location = /test {
        proxy_pass http://127.0.0.1:1214;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
    }

    # This location block is not needed as / is handled by the previous locations.
    # The connection to the Trojan protocol should be managed under its own route.
    location = / {
        proxy_pass http://127.0.0.1:1213;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
    }
}
```

```test.json
{
    "log": {
        "access": "/var/log/xray/test_access.log",
        "error": "/var/log/xray/test_error.log",
        "loglevel": "debug"
    },
    "inbounds": [
        {
            "listen": "127.0.0.1",
            "port": 10082,
            "protocol": "dokodemo-door",
            "settings": {
                "address": "127.0.0.1"
            },
            "tag": "api"
        },
        {
            "port": 1214,
            "listen": "127.0.0.1",
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password": "b654d3a9-ffaf-42ae-9ace-39aaf74775a2",
                        "level": 0,
                        "email": ""
  #trtls
                    },
                    {
                        "password": "trojanaku",
                        "level": 0,
                        "email": "testtrojan"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                    "path": "/test"
                }
            }
        }
    ],
    "outbounds": [
        {
            "tag":"Freedom",
            "protocol": "freedom",
            "settings": {}
        },
        {
            "protocol": "blackhole",
            "settings": {},
            "tag": "blocked"
        },
         {
            "tag":"warp",
            "protocol": "socks",
            "settings": {
                "servers": [
                    {
                        "address": "127.0.0.1",
                        "port": 1080,
                        "users": []
                    }
                ]
            }
        }
    ],
    "routing": {
        "rules": [
            {
                "type": "field",
                "ip": [
                    "0.0.0.0/8",
                    "10.0.0.0/8",
                    "100.64.0.0/10",
                    "169.254.0.0/16",
                    "172.16.0.0/12",
                    "192.0.0.0/24",
                    "192.0.2.0/24",
                    "192.168.0.0/16",
                    "198.18.0.0/15",
                    "198.51.100.0/24",
                    "203.0.113.0/24",
                    "::1/128",
                    "fc00::/7",
                    "fe80::/10"
                ],
                "outboundTag": "blocked"
            },
            {
                "inboundTag": [
                    "api"
                ],
                "outboundTag": "api",
                "type": "field"
            },
            {
                "type": "field",
                "outboundTag": "blocked",
                "protocol": [
                    "bittorrent"
                ]
            },
            {
                "type": "field",
                "network":"udp,tcp",
                "outboundTag": "warp"
            }
        ]
    },
    "stats": {},
    "api": {
        "services": [
            "StatsService"
        ],
        "tag": "api"
    },
    "policy": {
        "levels": {
            "0": {
                "statsUserDownlink": true,
                "statsUserUplink": true
            }
        },
        "system": {
            "statsInboundUplink": true,
            "statsInboundDownlink": true
        }
    }
}

```


## Xray Core (Support Custom Path)

https://github.com/dharak36/Xray-core


## AWS
- After testing with AWS EC2 Singapore seems like it throttle the outbound speed, so the max speed that I got when using the cf-warp routing reach max speed of 15MB/s