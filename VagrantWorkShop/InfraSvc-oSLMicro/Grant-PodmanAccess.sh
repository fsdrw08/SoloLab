# https://documentation.suse.com/sle-micro/5.1/single-html/SLE-Micro-podman/index.html#sec-podman-delivery
USER="vagrant"
sudo usermod --add-subuids 100000-165535 \
  --add-subgids 100000-165535 $USER