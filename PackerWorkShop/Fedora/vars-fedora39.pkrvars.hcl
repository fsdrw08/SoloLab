// https://ftp.kaist.ac.kr/pub/fedora/releases/
#iso_url="https://download.fedoraproject.org/pub/fedora/linux/releases/38/Server/x86_64/iso/Fedora-Server-dvd-x86_64-38-1.6.iso"
// https://download.fedoraproject.org/pub/fedora/linux/releases/38/Server/x86_64/iso/Fedora-Server-38-1.6-x86_64-CHECKSUM
iso_url="C:/Users/Public/Downloads/ISO/Fedora-Server-dvd-x86_64-39-1.5.iso"
iso_checksum="2755cdff6ac6365c75be60334bf1935ade838fc18de53d4c640a13d3e904f6e9"
iso_checksum_type="sha256"
vm_name="packer-fedora39-g2"
configuration_version="11.0"
disk_size="70000"
disk_additional_size=["150000"]
cd_files=[".\\http\\*"]
cd_label="cidata"
switch_name="Internal Switch"
output_directory="C:/ProgramData/Microsoft/Windows/Virtual Hard Disks/images/packer-fedora39/"
output_vagrant="../vbox/packer-fedora39-base-hv-g2.box"
vlan_id=""
vagrantfile_template="./vagrant-fedora39.rb"
// https://docs.fedoraproject.org/en-US/fedora/latest/install-guide/install/Booting_the_Installation/#:~:text=Fedora%20does%20not%20support%20UEFI%20booting%20for%2032-bit,fully%20supports%20version%202.2%20of%20the%20UEFI%20specification.
// !! the LABEL=Fedora-S-dvd-x86_64-38 is most important
// https://github.com/project-flotta/osbuild-operator/blob/89c69c4490522c0888bc83969d45fa2bc7cf7768/cmd/iso_package/grub_test.go
// boot_command=[
//   "c  setparams 'kickstart' <enter> linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=Fedora-S-dvd-x86_64-38 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks-fedora39.cfg<enter> initrdefi /images/pxeboot/initrd.img<enter> boot<enter>"
// ]

// https://github.com/brantleyp1/packer-image-builder/blob/dec07815501f30f2f96a653805048af5193ed333/rocky8.pkrvars.hcl
boot_command=[
  "c  setparams 'kickstart' <enter> linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=Fedora-S-dvd-x86_64-39 inst.ks=hd:LABEL=cidata:/ks-fedora39.cfg<enter> initrdefi /images/pxeboot/initrd.img<enter> boot<enter><wait30>"
]
