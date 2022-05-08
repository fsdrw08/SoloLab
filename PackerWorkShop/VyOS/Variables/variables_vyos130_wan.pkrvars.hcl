#iso_url=https://s3.amazonaws.com/s3-us.vyos.io/snapshot/vyos-1.3.0-rc6/vyos-1.3.0-rc6-amd64.iso
iso_url="../ISO/vyos-1.3.0-epa3-amd64.iso"
iso_checksum_type="sha256"
iso_checksum="40F4DAE80C7CB06406B6A866B5F5AD0E226B1B9D4EE110D8FC30148EDB0FFE37"
vm_name="packer-vyos130-epa3"
configuration_version="8.0"
disk_size="128000"
disk_additional_size=["150000"]
// https://www.packer.io/plugins/builders/hyperv/iso#cd_files
// cd_files=[".\\extra\\files\\gen2-vyos130\\initialConfig.sh"]
cd_files=[".\\extra\\files\\gen2-vyos130\\*"]
switch_name="Default Switch"
output_directory="output-vyos130"
output_vagrant="../vbox/packer-vyos130_wan-hv-g2.box"
vlan_id=""
vagrantfile_template="./vagrant/hv_vyos130_g2.rb"
ssh_username="vyos"
ssh_password="vyos"
provision_script_options="-z false"
// https://wiki.debian.org/CDDVD explanation for /dev/sr1
boot_command=["<wait3><enter><wait2><enter><wait2><enter>",
"<wait20>vyos<enter>",
"<wait3>vyos<enter>",
"<wait3>install image<enter>",
"<wait3><enter>",
"<wait3><enter>",
"<wait3><enter>",
"<wait3>yes<enter>",
"<wait3><enter>",
"<wait3><enter>",
"<wait3><enter>",
"<wait3>vyos<enter>",
"<wait3>vyos<enter>",
"<wait3><enter>",
"<wait7>shutdown -r now<enter>",
"<wait7><enter>",
"<wait30>vyos<enter>",
"<wait3>vyos<enter>",
"<wait3>sudo mount /dev/sr1 /mnt<enter>",
"<wait3>sudo /mnt/initialConfig-lite_wan.sh<enter>",
"<wait5>sudo umount /mnt<enter>",
]
