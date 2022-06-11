#iso_url="https://download.opensuse.org/distribution/leap-micro/5.2/product/iso/openSUSE-Leap-Micro-5.2-DVD-x86_64-Media.iso"
iso_url="../ISO/openSUSE-Leap-Micro-5.2-DVD-x86_64-Build38.1-Media.iso"
iso_checksum_type="sha256"
iso_checksum="c0aca8f48f72ff53e61d2a5757f654a8a6bc52dad847bf465fea052d340417c9"
vm_name="packer-opensuse-leap-micro-g2"
configuration_version="8.0"
disk_size="70000"
disk_additional_size=["150000"]
switch_name="Internal Switch"
output_directory="output-opensuse-leap-micro-base"
output_vagrant="../vbox/packer-opensuse-leap-micro-base-hv-g2.box"
vlan_id=""
vagrantfile_template="./hv_opensuse-leap-micro_g2.rb"
// https://github.com/thebridge0491/vm_templates_sh/blob/8e6bb63dae5986f813c3012ad2ae621c6a01d6ba/init/suse/packer-suse.json#L133
// https://en.opensuse.org/SDB:Linuxrc
// https://www.packer.io/plugins/builders/vsphere/vsphere-iso
boot_command=[
  "<wait>c<wait>linuxefi /boot/x86_64/loader/linux ",
  "netsetup=dhcp lang=en_US textmode=1 autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/autoyast.xml<enter><wait>",
  "initrdefi /boot/x86_64/loader/initrd<enter><wait3>",
  "boot<enter><wait600>"
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
