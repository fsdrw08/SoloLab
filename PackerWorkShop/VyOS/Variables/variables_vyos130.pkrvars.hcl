#iso_url=https://s3.amazonaws.com/s3-us.vyos.io/snapshot/vyos-1.3.0-rc5/vyos-1.3.0-rc5-amd64.iso
iso_url="D:\\Users\\Public\\Downloads\\ISO\\vyos-1.3.0-rc5-amd64.iso"
#iso_url="C:\\Users\\drw_0\\Downloads\\ISO\\vyos-1.3.0-rc5-amd64.iso"
iso_checksum_type="sha256"
iso_checksum="245B99C2EE92A0446CC5A24F5E169B06A6A0B1DD255BADFB4A8771B2BFD4C9DD"
vm_name="packer-vyos130rc5-g2"
disk_size="128000"
disk_additional_size=["150000"]
cd_files=[".\\extra\\files\\gen2-vyos130\\initialConfig.sh"]
switch_name="Internal Switch"
output_directory="output-vyos130rc4"
output_vagrant="./vbox/packer-vyos130rc5-hv-g2.box"
vlan_id=""
vagrantfile_template="./vagrant/hv_vyos130_g2.template"
ssh_username="vyos"
ssh_password="vyos"
provision_script_options="-z false"
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
"<wait3>sudo /mnt/initialConfig.sh<enter>",
"<wait5>sudo umount /mnt<enter>",
]
