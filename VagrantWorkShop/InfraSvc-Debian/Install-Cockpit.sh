# https://www.tutorialworks.com/podman-monitoring-cockpit-fedora/
# https://www.how2shout.com/how-to/how-to-install-cockpit-on-fedora-server.html
# sudo dnf install cockpit cockpit-pcp cockpit-podman -y
sudo apt-get install cockpit cockpit-pcp cockpit-podman -y

# sudo firewall-cmd --set-default-zone trusted

sudo systemctl enable --now cockpit.socket

# https://docs.fedoraproject.org/en-US/quick-docs/firewalld/
# sudo systemctl unmask firewalld

# sudo systemctl start firewalld

# sudo firewall-cmd --zone=public --add-service=cockpit --permanent
# sudo firewall-cmd --add-service=cockpit --permanent
