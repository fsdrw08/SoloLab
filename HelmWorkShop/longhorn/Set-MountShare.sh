sudo mount --make-rshared /
if [ -x /etc/init.d/k3s ] && [[ -z $(grep -l "mount --make-rshared" /etc/init.d/k3s) ]] ; then
  sudo sed -i 's#start_pre() {#start_pre() {\n    mount --make-rshared /#' /etc/init.d/k3s
fi
cat /etc/init.d/k3s