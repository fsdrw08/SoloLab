# https://access.redhat.com/discussions/4221861
sudo nmcli con mod 'eth0' +IPv4.address "192.168.255.31/24,192.168.255.32/24"
# sudo nmcli con mod 'eth0' IPv4.address 192.168.255.31/24
sudo nmcli con mod 'eth0' IPv4.gateway 192.168.255.1
# https://www.cnblogs.com/my-show-time/p/14220416.html
sudo nmcli con mod 'eth0' IPv4.dns "192.168.255.31,192.168.255.1"
sudo nmcli con mod 'eth0' IPv4.method manual
# sudo systemctl restart NetworkManager
# resolvectl status
# echo '192.168.255.31 ipa.infra.sololab' | sudo tee -a /etc/hosts