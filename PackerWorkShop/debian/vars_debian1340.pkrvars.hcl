# https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/
# https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.4.0-amd64-netinst.iso
# iso_url           = "D:/Users/Public/Downloads/ISO/debian-13.4.0-amd64-netinst.iso"
iso_url           = "C:/Users/Public/Downloads/ISO/debian-13.4.0-amd64-netinst.iso"
iso_checksum_type = "sha256"
# https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS
iso_checksum          = "0B813535DD76F2EA96EFF908C65E8521512C92A0631FD41C95756FFD7D4896DC"
vm_name               = "packer-debian1340-g2"
configuration_version = "12.0"
disk_size             = "70000"
cd_files              = [".\\http\\*"]
cd_label              = "cidata"
switch_name           = "Internal Switch"
output_directory      = "C:/ProgramData/Microsoft/Windows/Virtual Hard Disks/Images"
output_vagrant        = "C:/Users/Public/Downloads/vbox/packer-debian_1340-hv-g2.box"
vlan_id               = ""
# vagrantfile_template="./vagrant-debian1240.rb"
# https://github.com/vmware-samples/packer-examples-for-vsphere/blob/develop/builds/linux/debian/13/linux-debian.pkr.hcl
boot_command = [
  # This waits for 3 seconds, sends the "c" key, and then waits for another 3 seconds. In the GRUB boot loader, this is used to enter command line mode.
  "<wait3s>c<wait3s>",
  # This types a command to load the Linux kernel from the specified path.
  "linux /install.amd/vmlinuz",
  # This types a string that sets the auto-install/enable option to true. This is used to automate the installation process.
  " auto-install/enable=true",
  # This types a string that sets the debconf/priority option to critical. This is used to minimize the number of questions asked during the installation process.
  " debconf/priority=critical",
  # This types the value of the 'data_source_command' local variable. This is used to specify the kickstart data source configured in the common variables. 
  " preseed/file=/media/preseed13.cfg",
  # This types a string that sets the noprompt option and then sends the "enter" key. This is used to prevent the installer from pausing for user input.
  " noprompt --<enter>",
  # This types a command to load the initial RAM disk from the specified path and then sends the "enter" key.
  "initrd /install.amd/initrd.gz<enter>",
  # This types the "boot" command and then sends the "enter" key. This starts the boot process using the loaded kernel and initial RAM disk.
  "boot<enter>",
  # This waits for 30 seconds. This is typically used to give the system time to boot before sending more commands.
  "<wait30s>",
  # This sends the "enter" key and then waits. This is typically used to dismiss any prompts or messages that appear during boot.
  "<enter><wait>",
  # This sends the "enter" key and then waits. This is typically used to dismiss any prompts or messages that appear during boot.
  "<enter><wait>",
  # This types the value of the `mount_cdrom` local variable. This is typically used to mount the installation media.
  "<leftAltOn><f2><leftAltOff> <enter><wait> mount /dev/sr1 /media<enter> <leftAltOn><f1><leftAltOff>",
  # This sends four "down arrow" keys and then the "enter" key. This is typically used to select a specific option in a menu.
  "<down><down><down><down><enter>"
]

