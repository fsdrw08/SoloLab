#iso_url="https://mirrors.tuna.tsinghua.edu.cn/fedora/releases/36/Server/x86_64/iso/Fedora-Server-netinst-x86_64-36-1.5.iso"
iso_url="../ISO/Fedora-Server-netinst-x86_64-36-1.5.iso"
iso_checksum_type="sha256"
iso_checksum="421c4c6e23d72e4669a55e7710562287ecd9308b3d314329960f586b89ccca19"
vm_name="packer-fedora-g2"
configuration_version="8.0"
disk_size="70000"
disk_additional_size=["150000"]
switch_name="Internal Switch"
output_directory="output-fedora-base"
output_vagrant="../vbox/packer-fedora36-base-hv-g2.box"
vlan_id=""
vagrantfile_template="./vagrant-fedora36.rb"
// https://docs.fedoraproject.org/en-US/fedora/latest/install-guide/install/Booting_the_Installation/#:~:text=Fedora%20does%20not%20support%20UEFI%20booting%20for%2032-bit,fully%20supports%20version%202.2%20of%20the%20UEFI%20specification.
// !! the LABEL=Fedora-S-dvd-x86_64-36 is most important
// https://github.com/project-flotta/osbuild-operator/blob/89c69c4490522c0888bc83969d45fa2bc7cf7768/cmd/iso_package/grub_test.go
boot_command=[
  "c  setparams 'kickstart' <enter> linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=Fedora-S-dvd-x86_64-36 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks-fedora36.cfg<enter> initrdefi /images/pxeboot/initrd.img<enter> boot<enter>"
]
