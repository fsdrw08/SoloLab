#iso_url="https://download.opensuse.org/tumbleweed/iso/openSUSE-Tumbleweed-NET-x86_64-Current.iso"
iso_url="../ISO/openSUSE-Tumbleweed-DVD-x86_64-Current.iso"
// iso_checksum_type="sha256"
iso_checksum="none"
vm_name="packer-opensuse-tumbleweed-g2"
configuration_version="8.0"
cpus="2"
disk_size="70000"
switch_name="Internal Switch"
output_directory="output-opensuse-tumbleweed-base"
output_vagrant="../vbox/packer-opensuse-tumbleweed-base-hv-g2.box"
vlan_id=""
vagrantfile_template="./vagrant-openSUSE_tumbleweed.rb"
// https://github.com/thebridge0491/vm_templates_sh/blob/8e6bb63dae5986f813c3012ad2ae621c6a01d6ba/init/suse/packer-suse.json#L133
// https://en.opensuse.org/SDB:Linuxrc
// https://www.packer.io/plugins/builders/vsphere/vsphere-iso
boot_command=[
  "<wait>c<wait>linuxefi /boot/x86_64/loader/linux ",
  "netsetup=dhcp lang=en_US textmode=1 autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/autoyast-tumbleweed.xml<enter><wait>",
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
