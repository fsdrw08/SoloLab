sudo dnf update -y

# https://www.tutorialworks.com/podman-monitoring-cockpit-fedora/
# https://www.how2shout.com/how-to/how-to-install-cockpit-on-fedora-server.html
sudo dnf install podman net-tools cockpit cockpit-pcp cockpit-podman -y

sudo systemctl enable --now cockpit.socket

# https://docs.fedoraproject.org/en-US/quick-docs/firewalld/
sudo systemctl unmask firewalld

sudo systemctl start firewalld

sudo firewall-cmd --add-service=cockpit

sudo firewall-cmd --add-service=cockpit --permanent

