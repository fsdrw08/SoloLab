#!/bin/bash
sudo sed -i -e 's|*.UseDNS.*|UseDNS no|g' /etc/ssh/sshd_config
sudo sed -i -e 's|*.PermitRootLogin.*|PermitRootLogin no|g' /etc/ssh/sshd_config