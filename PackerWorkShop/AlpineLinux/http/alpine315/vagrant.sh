set -exu

date > /etc/vagrant.timestamp

#
# bash for vagrant (default shell is bash)
#   doesn't look like there is an easy way for vagrant guest
#   plugin to register a default shell. easier than always
#   having to *remember* to configure `ssh.shell` for
#   alpine boxes.
#
# cURL for initial vagrant key install from vagrant github repo.
#   on first 'vagrant up', overwritten with a local, secure key.
#

adduser -D vagrant
echo "vagrant:vagrant" | chpasswd

mkdir -pm 700 /home/vagrant/.ssh

curl -sSo /home/vagrant/.ssh/authorized_keys 'https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub'

chown -R vagrant:vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

ls -Alh /home/vagrant/.ssh