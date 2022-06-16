// https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/
#iso_url="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.0.0-amd64-netinst.iso"
// iso_url="../ISO/debian-11.3.0-amd64-netinst.iso"
// https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/
iso_url="../ISO/debian-11.3.0-amd64-DVD-1.iso"
iso_checksum_type="sha256"
// https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS
iso_checksum="fab0b6d2ea4fa4fb14100225fcb2988b94a8e391f273b4bfaed6314dff124a42"
vm_name="packer-debian1130-g2"
configuration_version="8.0"
disk_size="70000"
switch_name="Internal Switch"
output_directory="output-debian1130"
output_vagrant="../vbox/packer-debian1130-hv_g2.box"
vlan_id=""
vagrantfile_template="./vagrant-debian11.rb"
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

