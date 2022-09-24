sudo nmcli con mod 'eth0' IPv4.address 192.168.255.31/24
sudo nmcli con mod 'eth0' IPv4.gateway 192.168.255.1
sudo nmcli con mod 'eth0' IPv4.dns 192.168.255.1
sudo nmcli con mod 'eth0' IPv4.method manual