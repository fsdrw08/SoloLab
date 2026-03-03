#iso_url=https://github.com/9l/vyos-build-action/releases/download/v1.3.2/vyos-1.3.2-amd64.iso
iso_url="../ISO/vyos-1.3.3-amd64.iso"
iso_checksum_type="sha256"
iso_checksum="1803F55692B6025F306E7F664EC94E328D4941BB48D6EEA865EF78B01CE6E472"
vm_name="packer-vyos13x"
configuration_version="8.0"
disk_size="128000"
// disk_additional_size=["150000"]
// https://www.packer.io/plugins/builders/hyperv/iso#cd_files
cd_files=[".\\http\\*"]
switch_name="Default Switch"
output_directory="C:/ProgramData/Microsoft/Windows/Virtual Hard Disks/output-vyos13x"
output_vagrant="../vbox/packer-vyos13x_wan-hv-g2.box"
vlan_id=""
vagrantfile_template="./vagrant-VyOS13x.rb"
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
"<wait3>sudo /mnt/provision.sh<enter>",
"<wait5>sudo umount /mnt<enter>",
"<wait3>sudo poweroff<enter>",
]
