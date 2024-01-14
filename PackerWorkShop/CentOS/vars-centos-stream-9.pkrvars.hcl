// https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/
// iso_url="https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso"
// iso_checksum=https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso.SHA256SUM
// iso_url="C:/Users/Public/Downloads/ISO/CentOS-Stream-9-latest-x86_64-dvd1.iso"
// iso_checksum="a8b4ae4aa0edcd911aa35205f27a4592d361f771d8e68cad34664b15612fb396"
iso_url="C:/Users/Public/Downloads/ISO/CentOS-Stream-9-20230918.0-x86_64-boot.iso"
iso_checksum_type="sha256"
iso_checksum="bde1302e56ca15870372b5e774243b7a6496e96bb8aaeb62418a0a3e63534ef7"
vm_name="packer-centos-stream-9-g2"
configuration_version="11.0"
disk_size="70000"
cd_files=[".\\http\\*"]
cd_label="cidata"
switch_name="Internal Switch"
output_directory="C:/ProgramData/Microsoft/Windows/Virtual Hard Disks/output-centos-stream-9-base"
output_vagrant="../vbox/packer-centos-stream-9-hv-g2.box"
vlan_id=""
vagrantfile_template="./vagrant-centos-stream-9.rb"
// https://docs.fedoraproject.org/en-US/fedora/latest/install-guide/install/Booting_the_Installation/#:~:text=Fedora%20does%20not%20support%20UEFI%20booting%20for%2032-bit,fully%20supports%20version%202.2%20of%20the%20UEFI%20specification.
// !! the LABEL=Fedora-S-dvd-x86_64-38 is most important
// https://github.com/project-flotta/osbuild-operator/blob/89c69c4490522c0888bc83969d45fa2bc7cf7768/cmd/iso_package/grub_test.go
// boot_command=[
//   "c  setparams 'kickstart' <enter> linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=Fedora-S-dvd-x86_64-38 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks-fedora38.cfg<enter> initrdefi /images/pxeboot/initrd.img<enter> boot<enter>"
// ]

// https://github.com/brantleyp1/packer-image-builder/blob/dec07815501f30f2f96a653805048af5193ed333/rocky8.pkrvars.hcl
// https://github.com/osbuild/osbuild-composer/issues/3059
boot_command=[
  "c  setparams 'kickstart' <enter> linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=CentOS-Stream-9-BaseOS-x86_64 inst.ks=hd:LABEL=cidata:/ks-centos-stream-9.cfg<enter> initrdefi /images/pxeboot/initrd.img<enter> boot<enter><wait30>"
]
