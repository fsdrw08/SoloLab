// 76492d1116743f0423413b16050a5345MgB8AFUAbQAxAEwAdwA3AHoAawBoADQAUgBzAFEAQwBSAEEAdgBUAG0AZgBRAHcAPQA9AHwANgA5ADcA
// ZQBhADQAMwA2ADAAZAA1AGEAYwA0ADEAOAA1AGQAYQAwADYAMQBjADYANQA4ADIAYQBhADcANgA0ADMANAAxADAAYwBhAGQANQAwADYANABlADMA
// MwAyADQAMAAyADEAMAAzAGIANwBlAGQANAA0AGYAOQAwADMAZgBiAGIANQA5ADAAMAA0ADUAYwBlADQAYgA4AGIAZQBjAGIANgBkAGUAYwBkADMA
// NwA3AGIAOABiAGYAZABiAGEAOABkADgAMgAzADAANQAxADQANwBkADEAMwBhADQAMABkAGQAYQAzADEANQA3ADUAMgAyADUAOAA5AGQAYwA4AGMA
// MQBiAGQAOAA4ADcAMQBkAGIAZAAxAGEAOAA1AGYANgA4ADEANwAxAGYANgBjADcAYgA0AGQAZQBmAGQAZQAwADkANgA4ADMAMgBkADUANwBiADgA
// MQAwAGUAMQA4ADgAYwAzADgAMAAzADEAYQBlAGEAYgBlADEANgA3AGMANgAxADQANwAyADgAMwBmADIANQAwAGYAYgA1AGQAMgBiAGYAZABlADAA
// NQA3AGEAYwAwAGUAMAA4AGQAMABiADQAYgA1ADIAYgBmADQAZgBlAGIAMAAyAGYAYQA4AGQANwBjADcAYgBjADcAMgA1AGUAOQA1ADUAZgAwAGEA
// MAAwADUAOQBiAGMAZAAyAGYAOQA0ADAANAA0AGEAOAAxADEAZQA5AGUAZABmADgAZABmAGEAMQAyAGEAMAAxADIANwBmADcAZgBmAGEAYQAxADcA
// YgBlADQAYwBhADMAOAA0AGUAMwAzADMAMwA0ADAAYgAzADIANgAwAGIAMQBkADUAOQBjAGIAOQA1AGEAZABkADYAMgAyADEAZQBiAGQAYQA5ADMA
// ZAA2ADAAZAAxAGIAMQBkAGQANABlAGUAMABjADIAMgAxADEANQBhADIANQAzADYAMQBlADIAZQBjAGEAOQA0ADMAOABkADUANgA4AGUAOAAwADUA
// OABiAGUAZABlAGUANwAwADEAZABiADYAYgAwAGIANAAyAGQAZAA2ADYAOQBmADEAMAA0AGIAMAAwADgAZABiADgAYwAzAA==

// aHR0cHM6Ly93d3cucGRxLmNvbS9ibG9nL3NlY3VyZS1wYXNzd29yZC13aXRoLXBvd2Vyc2hlbGwtZW5jcnlwdGluZy1jcmVkZW50aWFscy1wYXJ0LTIv
// JHVybCA9IFJlYWQtSG9zdCAtQXNTZWN1cmVTdHJpbmcKJGVuY3J5cHRlZF91cmxfd19rZXkgPSBDb252ZXJ0RnJvbS1TZWN1cmVTdHJpbmcgLVNlY3VyZVN0cmluZyAkdXJsIC1LZXkgKDEuLjE2KQokZW5jcnlwdGVkX3VybF93X2tleSA9ICIiCiRzZWN1cmVfc3RyaW5nX2VuY3J5cHRlZF91cmxfa2V5ID0gJGVuY3J5cHRlZF91cmxfd19rZXkgfCBDb252ZXJ0VG8tU2VjdXJlU3RyaW5nIC1LZXkgKDEuLjE2KQpDb252ZXJ0RnJvbS1TZWN1cmVTdHJpbmcgLVNlY3VyZVN0cmluZyAkc2VjdXJlX3N0cmluZ19lbmNyeXB0ZWRfdXJsX2tleSAtQXNQbGFpblRleHQ=

iso_url               = "C:/Users/Public/Downloads/ISO/vyos-1.4.0-generic-amd64.iso"
iso_checksum_type     = "sha256"
iso_checksum          = "B276D133CBC949507BE6C08FAA57EE035D2D6A6CD066CC41F0C0EFF1FD5235E1"
vm_name               = "packer-vyos140"
configuration_version = "11.0"
disk_size             = "128000"
// disk_additional_size=["150000"]
// https://www.packer.io/plugins/builders/hyperv/iso#cd_files
cd_files                 = [".\\http\\*"]
switch_name              = "Default Switch"
output_directory         = "C:/ProgramData/Microsoft/Windows/Virtual Hard Disks/Images/packer-vyos140-ga/"
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
  // "<wait9>sudo /mnt/provision-sagitta-cloud-init.sh && sudo /mnt/provision-cleanup.sh && sudo umount /mnt && sudo poweroff<enter>"
  "<wait9>sudo /mnt/provision-sagitta-cloud-init.sh && echo 'sudo /mnt/provision-cleanup.sh && sudo umount /mnt && sudo poweroff'<enter>",
  // "<wait1200>sudo /mnt/provision-cleanup.sh && sudo umount /mnt && sudo poweroff<enter>"
  // "sudo /mnt/provision-cleanup.sh && sudo umount /mnt && sudo poweroff<enter>"
  // "<wait70>sudo /mnt/provision-cleanup.sh<enter>",
  // "<wait5>sudo umount /mnt<enter>",
  // "<wait3>sudo poweroff<enter>"
]
