// https://mirrors.ustc.edu.cn/opensuse/distribution/leap/15.6/iso/
iso_url="C:/Users/Public/Downloads/ISO/openSUSE-Leap-15.6-DVD-x86_64-Build525.1-Media.iso"
iso_checksum="6cb9d4893ffbafe52ad4b6be9a2969ff8a392622fc135baab89f2520651b510b"
// iso_url="C:/Users/Public/Downloads/ISO/openSUSE-Leap-15.5-NET-x86_64-Build491.1-Media.iso"
// iso_checksum="a2f7f2f1b6b3d3ef96f5c8f804d87ebd01e5cf982357c533f4c39c33cd20ec56"
iso_checksum_type="sha256"
vm_name="packer-opensuse-leap-g2"
configuration_version="11.0"
cpus="2"
cd_files=[".\\http\\*"]
disk_size="70000"
switch_name="Internal Switch"
output_directory="C:/ProgramData/Microsoft/Windows/Virtual Hard Disks/output-opensuse-leap-15.6-base"
// output_vagrant="../vbox/packer-opensuse-leap-base-hv-g2.box"
vlan_id=""
vagrantfile_template="./vagrant-openSUSE_leap.rb"
// https://en.opensuse.org/SDB:Linuxrc
// https://www.packer.io/plugins/builders/vsphere/vsphere-iso
// https://github.com/thebridge0491/vm_templates_sh/blob/8e6bb63dae5986f813c3012ad2ae621c6a01d6ba/init/suse/packer-suse.json#L133
// https://en.opensuse.org/SDB:Linuxrc
// https://documentation.suse.com/sles/12-SP5/html/SLES-all/Invoking.html#:~:text=autoyast%3Dlabel%3A//LABEL/PATH
boot_command=[
  "<wait>c<wait>linuxefi /boot/x86_64/loader/linux ",
  "netsetup=dhcp textmode=1 lang=en_US autoyast=label://cidata/autoyast-Leap_15.6.xml<enter><wait>",
  "initrdefi /boot/x86_64/loader/initrd<enter><wait3>",
  "boot<enter><wait>"
]
