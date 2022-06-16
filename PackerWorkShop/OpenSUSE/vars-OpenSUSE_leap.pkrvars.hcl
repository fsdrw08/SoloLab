#iso_url="https://download.opensuse.org/distribution/leap/15.4/iso/openSUSE-Leap-15.4-DVD-x86_64-Media.iso.meta4"
iso_url="../ISO/openSUSE-Leap-15.4-DVD-x86_64-Build243.2-Media.iso"
iso_checksum_type="sha256"
iso_checksum="4683345f242397c7fd7d89a50731a120ffd60a24460e21d2634e783b3c169695"
vm_name="packer-opensuse-leap-g2"
configuration_version="8.0"
disk_size="70000"
switch_name="Internal Switch"
output_directory="output-opensuse-leap-base"
output_vagrant="../vbox/packer-opensuse-leap-base-hv-g2.box"
vlan_id=""
vagrantfile_template="./vagrant-openSUSE_leap.rb"
// https://github.com/thebridge0491/vm_templates_sh/blob/8e6bb63dae5986f813c3012ad2ae621c6a01d6ba/init/suse/packer-suse.json#L133
// https://en.opensuse.org/SDB:Linuxrc
// https://www.packer.io/plugins/builders/vsphere/vsphere-iso
boot_command=[
  "<wait>c<wait>linuxefi /boot/x86_64/loader/linux ",
  "netsetup=dhcp lang=en_US textmode=1 autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/autoyast-leap.xml<enter><wait>",
  "initrdefi /boot/x86_64/loader/initrd<enter><wait3>",
  "boot<enter><wait240>"
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
