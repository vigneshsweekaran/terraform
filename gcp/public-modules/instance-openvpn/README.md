##

### Install openvpn
```
wget https://git.io/vpn -O openvpn-install.sh
sudo bash openvpn-install.sh
```

## Add the lines in file /etc/openvpn/server/server.conf
```
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
```

```
sudo systemctl restart openvpn-server@server.service
sudo systemctl restart openvpn
```

### Download the file
```
gcloud compute scp openvpn-server:/home/vigneshsweekaran/macbook.ovpn ~/Downloads --zone=us-central1-a
```