#iso_url="https://download.opensuse.org/distribution/leap/15.4/iso/openSUSE-Leap-15.4-DVD-x86_64-Media.iso.meta4"
iso_url="C:/Users/Public/Downloads/ISO/openSUSE-Leap-15.5-NET-x86_64-Build491.1-Media.iso"
iso_checksum_type="sha256"
iso_checksum="a2f7f2f1b6b3d3ef96f5c8f804d87ebd01e5cf982357c533f4c39c33cd20ec56"
vm_name="packer-opensuse-leap-g2"
configuration_version="8.0"
cpus="2"
cd_files=[".\\http\\*"]
disk_size="70000"
switch_name="Internal Switch"
output_directory="C:/ProgramData/Microsoft/Windows/Virtual Hard Disks/output-opensuse-leap-15.5-base"
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
  "netsetup=dhcp lang=en_US textmode=1 autoyast=label://cidata/autoyast-Leap_15.5.xml<enter><wait>",
  "initrdefi /boot/x86_64/loader/initrd<enter><wait3>",
  "boot<enter><wait>"
]
//   "initrdefi /boot/x86_64/loader/initrd<enter><wait10>boot<enter><wait10>"
// boot_command=[
//   // boot UI
//   "<enter><wait180>",
//   // language
//   "<leftAltOn>n<leftAltOff><wait30>",
//   // ntp
//   "<leftAltOn>n<leftAltOff><wait5>",
//   // root password
//   "root<tab><wait>",
//   "root<tab><wait>",
//   "<leftAltOn>n<leftAltOff><wait5>",
//   // confirm too simple password
//   "<leftAltOn>y<leftAltOff><wait5>",
//   // installation settings
//   "<leftAltOn>i<leftAltOff><wait5>",
//   // confirm
//   "<leftAltOn>i<leftAltOff><wait120>",
//   // first login
//   "root<enter><wait>"
//   "root<enter><wait>"
// ]
