#iso_url="https://dl-cdn.alpinelinux.org/alpine/v3.14/releases/x86_64/alpine-virt-3.14.2-x86_64.iso"
#iso_url="../ISO/alpine-standard-3.14.0-x86_64.iso"
iso_url="../ISO/alpine-virt-3.16.1-x86_64.iso"
iso_checksum_type="sha256"
iso_checksum="ce507d7f8a0da796339b86705a539d0d9eef5f19eebb1840185ce64be65e7e07"
vm_name="packer-alpine316-g2"
configuration_version="8.0"
disk_size="70000"
switch_name="Internal Switch"
output_directory="output-alpine316-base"
output_vagrant="../vbox/packer-alpine316-base-hv-g2.box"
vlan_id=""
vagrantfile_template="./vagrant-alpine316.rb"
alpine_version="3.16"
mirror="https://mirrors.tuna.tsinghua.edu.cn/alpine/"
boot_command=[
    "root<enter><wait5>",
    "ifconfig eth0 up && udhcpc -i eth0<enter><wait5>",
    "wget -qO- http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.sh | ash<enter><wait120>",
    "root<enter><wait5>",
    "root<enter><wait5>",
    "ifconfig eth0 up && udhcpc -i eth0<enter><wait5>",
    "apk add hvtools dhclient<enter><wait10>",
    "rc-update add hv_fcopy_daemon && rc-service hv_fcopy_daemon start<enter><wait>",
    "rc-update add hv_kvp_daemon && rc-service hv_kvp_daemon start<enter><wait>",
    "rc-update add hv_vss_daemon && rc-service hv_vss_daemon start<enter><wait>",
    "exit<enter>"
]