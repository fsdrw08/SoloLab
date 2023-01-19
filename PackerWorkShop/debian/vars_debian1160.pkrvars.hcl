// https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/
#iso_url="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.5.0-amd64-netinst.iso"
// iso_url="../ISO/debian-11.5.0-amd64-netinst.iso"
// https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/
iso_url="../ISO/debian-11.6.0-amd64-netinst.iso"
iso_checksum_type="sha256"
// https://cdimage.debian.org/debian-cd/11.6.0/amd64/iso-cd/SHA256SUMS
iso_checksum="e482910626b30f9a7de9b0cc142c3d4a079fbfa96110083be1d0b473671ce08d"
vm_name="packer-debian1160-g2"
configuration_version="8.0"
disk_size="70000"
switch_name="Internal Switch"
output_directory="output-debian1160"
output_vagrant="../vbox/packer-debian1160-hv_g2.box"
vlan_id=""
vagrantfile_template="./vagrant-debian1160.rb"
boot_command=[
  "c<wait>",
  "linux /install.amd/vmlinuz",
  " auto=true",
  " url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
  " hostname=debian",
  " domain=''",
  "<enter>",
  "initrd /install.amd/initrd.gz<enter>",
  "boot<enter>"
]

