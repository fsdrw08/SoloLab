#iso_url="https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-virt-3.16.3-x86_64.iso"
iso_url="../ISO/alpine-virt-3.16.3-x86_64.iso"
iso_checksum_type="sha256"
// https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-virt-3.16.3-x86_64.iso.sha256
iso_checksum="a90150589e493d5b7e87297056b6e124d8af1b91fa2eb92bab61a839839e287b"
vm_name="packer-AlpineLinux316-g2"
configuration_version="8.0"
disk_size="70000"
switch_name="Internal Switch"
output_directory="output-AlpineLinux316-base"
output_vagrant="../vbox/packer-AlpineLinux316-base-hv-g2.box"
vlan_id=""
vagrantfile_template="./vagrant-AlpineLinux316.rb"
alpine_version="316"
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