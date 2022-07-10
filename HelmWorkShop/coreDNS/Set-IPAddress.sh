sed -i -e "s/IPADDRESS/$(ip -4 -o addr show eth0 | awk '{print $4}' | cut -d "/" -f 1)/" \
  $(dirname "$0")/CM-coredns-custom.yaml  \
  && cat $(dirname "$0")/CM-coredns-custom.yaml
