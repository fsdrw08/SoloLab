// 76492d1116743f0423413b16050a5345MgB8ADQAbQBYAE0ASwBJAHkAMwBpAE8ATwB3AG8AbwBrAFMAOABsAFYAVgBnAEEAPQA9AHwAYwA2ADYAMQA2ADEAMQAzADEANQA5AG
// YAMQBhADkAMgBiADMAOAA5ADcANQBmAGEANABlAGUAMgAwADEAYwA3AGYAOQA3ADcANQA1AGUAZgAyADAAMgBiADYANAA3ADkANwA1ADkAMQA5AGIANgBjADUANwA5AGMAYgBj
// AGMAMwAyAGYANwBjADkAOABjADIANAA0AGQAMABjADgANAA1ADgAZQA1ADAAMABlAGUANwAxADkANAAxAGEAMABlAGYANwBhAGUAOAA0ADcANwA5ADEAYQAxADEAYgA2AGYAYwA
// xADAAMABlADcAOAAxADYAMwAzADMAMgAyADYAYQA5AGYAMAAxADUANwAwADAAMwBiADIANwAwAGEAOABjADAAZQA4ADQAMgBlADQAMAAyAGEAMQAwADUAMQA4AGIANAA4ADgAMAA
// 3ADMAYgBiAGMANwBlADIAOAA1AGUAZgBmADgAMgAzADAANgBiAGYANABmADUAYwBhADQANAA1AGMAZQA4AGQANgBkADYAYwA1ADgAYQBhADMAMQBjAGUAMwAwADAAOQA2ADYAOQB
// mADEAZABkADQAMQBhADcAMABkAGYAOQBjAGEANQA2AGQAZQBhADEAZgBmADMAYwBhADIAZQA0AGMAMABkADMAYgBiAGQAYwAzADcAMgAzADUANgA5ADQAZQA0AGMAZQA0AGMAMgA
// 0AGMANQA0AGMANQBjAGIAMwBiAGEAMwA5AGMAOQAwADYAZQA0AGMAZQA4ADEAMAA0ADIAMwBiADEAOAA1ADIANQA5ADYAMwAzAGIANgAzADYAYgAyADQAZQA1AGEAYgA4ADEAZgA2
// ADEAMQAwADUAYQA1ADQAZgBhADQAOAA4ADEAMQBmAGUAYwBlADUANgBkADIAMQA2ADIAYgAzAGEANQBlAGEAMwBiAGUANAAwADcAOQA4AGQAYgA1AGMAYgAwAGUAOABiADQAMQBhAG
// QAMgBkADEANQBiADIANAAxAGUAMABmAGEANQAxADgAYgA3AGQAYQAzADAAYwBiAGUANgAxAGIAMQA2AGUANgA5AGIAYQA0ADgAYgBjADkAMQA5ADEAZAAxAGMANgBmAGMAYwAzAGIAY
// wA2ADAAMAAyADkANgBhADEAOQA3AGMAOQBhAGMAZQAyAGUAOABlADkAYQA4ADQAOQBjAGMAZQA=

// Ly8gJHB3ZCA9IFJlYWQtSG9zdCAtQXNTZWN1cmVTdHJpbmcKLy8gJGVuY3J5cHRlZF9wd2Rfd19rZXkgPSBDb252ZXJ0RnJvbS1TZWN1cmVTdHJpbmcgLVNlY3VyZVN0cmluZyAkcH
// dkIC1LZXkgKDEuLjE2KQovLyAkc2VjdXJlX3N0cmluZ19lbmNyeXB0ZWRfcHdkX2tleSA9ICRlbmNyeXB0ZWRfcHdkX3dfa2V5IHwgQ29udmVydFRvLVNlY3VyZVN0cmluZyAtS2V5
// ICgxLi4xNikKLy8gQ29udmVydEZyb20tU2VjdXJlU3RyaW5nIC1TZWN1cmVTdHJpbmcgJHNlY3VyZV9zdHJpbmdfZW5jcnlwdGVkX3B3ZF9rZXkgLUFzUGxhaW5UZXh0

iso_url               = "C:/Users/Public/Downloads/ISO/vyos-1.4.0-epa3-amd64.iso"
iso_checksum_type     = "sha256"
iso_checksum          = "2A639ED06FAB6C0D254A765AD458224230A5470F7BBFC34730ED410E01AA9CAC"
vm_name               = "packer-vyos140"
configuration_version = "11.0"
disk_size             = "128000"
// disk_additional_size=["150000"]
// https://www.packer.io/plugins/builders/hyperv/iso#cd_files
cd_files                 = [".\\http\\*"]
switch_name              = "Default Switch"
output_directory         = "C:/ProgramData/Microsoft/Windows/Virtual Hard Disks/Images/packer-vyos140/"
output_vagrant           = "../vbox/packer-vyos14x_wan-hv-g2.box"
vlan_id                  = ""
vagrantfile_template     = "./vagrant-VyOS14x.rb"
ssh_username             = "vyos"
ssh_password             = "vyos"
// https://wiki.debian.org/CDDVD explanation for /dev/sr1
boot_command = [
  // https://github.com/vyos/vyos-build/blob/current/scripts/check-qemu-install
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
  //
  "<wait45>vyos<enter>",
  "<wait3>vyos<enter>",
  "<wait3>sudo mount /dev/sr1 /mnt<enter>",
  "<wait3>sudo /mnt/provision-dhcp.sh<enter>",
  "<wait9>sudo /mnt/provision-sagitta-cloud-init.sh && sudo /mnt/provision-cleanup.sh && sudo umount /mnt && sudo poweroff<enter>"
  // "<wait70>sudo /mnt/provision-cleanup.sh<enter>",
  // "<wait5>sudo umount /mnt<enter>",
  // "<wait3>sudo poweroff<enter>"
]
