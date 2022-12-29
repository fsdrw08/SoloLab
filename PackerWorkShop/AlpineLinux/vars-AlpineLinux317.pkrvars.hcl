#iso_url="https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-virt-3.16.3-x86_64.iso"
iso_url="../ISO/alpine-virt-3.17.0-x86_64.iso"
iso_checksum_type="sha256"
// https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-virt-3.16.3-x86_64.iso.sha256
iso_checksum="8d4d53bd34b2045e1e219b87887b0de8d217b6cd4a8b476a077429845a5582ba"
vm_name="packer-AlpineLinux317-g2"
configuration_version="8.0"
disk_size="70000"
switch_name="Internal Switch"
output_directory="output-AlpineLinux317-base"
output_vagrant="../vbox/packer-AlpineLinux317-base-hv-g2.box"
vlan_id=""
vagrantfile_template="./vagrant-AlpineLinux317.rb"
alpine_version="317"
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