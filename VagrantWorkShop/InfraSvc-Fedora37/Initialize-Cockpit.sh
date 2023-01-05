sudo systemctl enable --now cockpit.socket

# https://docs.fedoraproject.org/en-US/quick-docs/firewalld/
sudo systemctl unmask firewalld

sudo systemctl start firewalld

sudo firewall-cmd --add-service=cockpit

sudo firewall-cmd --add-service=cockpit --permanent

