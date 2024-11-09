#iso_url=https://github.com/vyos/vyos-nightly-build/releases/download/1.5-rolling-202411070006/vyos-1.5-rolling-202411070006-generic-amd64.iso
iso_url               = "C:/Users/Public/Downloads/ISO/vyos-1.5-rolling-202411070006-generic-amd64.iso"
iso_checksum_type     = "sha256"
iso_checksum          = "C34E117E38A82495861874921AA605DAD38A31EA059D0108917465EF23E1A7D9"
vm_name               = "packer-vyos150"
configuration_version = "11.0"
disk_size             = "128000"
// disk_additional_size=["150000"]
// https://www.packer.io/plugins/builders/hyperv/iso#cd_files
cd_files                 = [".\\http\\*"]
switch_name              = "Default Switch"
output_directory         = "C:/ProgramData/Microsoft/Windows/Virtual Hard Disks/Images/packer-vyos150/"
output_vagrant           = "C:/Users/Public/Downloads/vbox/packer-vyos15x-hv-g2.box"
vlan_id                  = ""
vagrantfile_template     = "./vagrant-VyOS15x.rb"
skip_export              = true
ssh_username             = "vyos"
ssh_password             = "vyos"
// https://wiki.debian.org/CDDVD explanation for /dev/sr1
boot_command = [
  // "<wait600><enter><wait2><enter><wait2><enter>",
  // vyos login
  "<wait60>vyos<enter>",
  // password
  "<wait3>vyos<enter>",
  // https://docs.vyos.io/en/equuleus/installation/install.html#permanent-installation
  // start install
  "<wait3>install image<enter>",
  // Would you like to continue? (y/N):
  "<wait3>y<enter>",
  // What would you like to name this image? (Default: ...)
  "<wait3><enter>",
  // Please enter a password for the "vyos" user
  "<wait3>vyos<enter>",
  // Please confirm password for the "vyos" user
  "<wait3>vyos<enter>",
  // what console should be used by default? (K: KVM, S: Serial, U: USB-Serial)? (Default: K)
  "<wait3><enter>",
  // Which one should be used for installation? (Default: /dev/sda)
  "<wait3><enter>",
  // Installation will delete all data on the drive. Continue? [y/N]
  "<wait3>y<enter>",
  // Would you like to use all the free space on the drive? [Y/n]
  "<wait3>y<enter>",
  // https://github.com/vyos/vyos-1x/blob/c3c81dcc0a79c1ab1bc9a13c62565a69ee5550fa/src/op_mode/image_installer.py#L748
  // the following config files are available for boot:
  // 1. /opt/vyatta/etc/config/config.boot
  // 2. /opt/vyatta/etc/config.boot.default
  // Which file would you like as boot config? (Default: 1)
  "<wait3><enter>",
  // The image installed successfully; please reboot now
  "<wait20>reboot<enter>",
  // Are you sure you want to reboot this system? [y/N]
  "<wait3>y<enter>",
  // you might need to manually eject the installation iso and reboot the VM in these 45 seconds
  "<wait45>vyos<enter>",
  "<wait3>vyos<enter>",
  "<wait3>sudo mount /dev/sr1 /mnt<enter>",
  "<wait3>sudo /mnt/provision-dhcp.sh<enter>",
  // "<wait9>sudo /mnt/provision-circinus-cloud-init.sh && sudo /mnt/provision-cleanup.sh && sudo umount /mnt && sudo poweroff<enter>"
  "<wait9>sudo /mnt/provision-circinus-cloud-init.sh && echo 'sudo /mnt/provision-cleanup.sh && sudo /mnt/provision-vagrant.sh && sudo umount /mnt && sudo poweroff'<enter>",
  // "<wait70>sudo /mnt/provision-cleanup.sh<enter>",
  // "<wait5>sudo umount /mnt<enter>",
  // "<wait3>sudo poweroff<enter>"
]
