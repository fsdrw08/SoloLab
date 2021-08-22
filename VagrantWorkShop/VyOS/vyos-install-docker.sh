#!/usr/bin/bash
# v0.1.0

user=$(id -u)
docker_comp_ver='1.29.2'

# Check if running as root
[ "$user" != 0 ] && echo "Run script as root, exiting" && exit 1 

# Install docker req
echo "deb http://deb.debian.org/debian buster main contrib non-free" >> /etc/apt/sources.list
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# Add docker repo
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/debian buster stable"  >> /etc/apt/sources.list
apt-get update

# Make persistent var for docker to live between vyos upgrades
mkdir -p /config/user-data/docker
ln -s /config/user-data/docker /var/lib/docker

# Install docker and docker-compose
apt-get install -y docker-ce docker-ce-cli containerd.io
curl -L "https://get.daocloud.io/docker/compose/releases/download/$docker_comp_ver/docker-compose-$(uname -s)-$(uname -m)" -o /config/user-data/docker/docker-compose
chmod +x /config/user-data/docker/docker-compose
ln -s /config/user-data/docker/docker-compose /usr/local/bin/docker-compose

# Stop docker service from autostart since we need to start manual AFTER vyos finish with iptables
sudo systemctl disable docker

# We can autostart now
echo 'systemctl start docker' >> /config/scripts/vyos-postconfig-bootup.script

# After making changes to the firewall you have to run systemctl restart docker
systemctl restart docker

# Check if docker service is started
systemctl status docker &>/dev/null; ret_docker="$?"
if [ "$ret_docker" == 0 ]; then
  echo -e "\nDocker succesfully installed"
else
  echo -e "\nUPS, Docker service is not running"
fi  