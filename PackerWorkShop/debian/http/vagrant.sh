#!/bin/bash
echo "Executing scripts/vagrant.sh"
mkdir -pm 700 /home/vagrant/.ssh
curl -sL https://gitee.com/mirrors/vagrant/raw/main/keys/vagrant.pub -o /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
cat > /etc/sudoers.d/vagrant << EOF_sudoers_vagrant
vagrant        ALL=(ALL)       NOPASSWD: ALL
Defaults:vagrant !requiretty
EOF_sudoers_vagrant
/bin/chmod 0440 /etc/sudoers.d/vagrant
/bin/sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
ls -al /home/vagrant/
