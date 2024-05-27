iso_url               = "C:/Users/Public/Downloads/ISO/OPNsense-24.1-dvd-amd64.iso"
iso_checksum_type     = "sha256"
iso_checksum          = "348941A4E00BD57B6E8515D32F7A78C43E0087746D13939AD507A1EC3445BD97"
vm_name               = "packer-opnsense24"
configuration_version = "11.0"
disk_size             = "128000"
// https://www.packer.io/plugins/builders/hyperv/iso#cd_files
cd_files                 = [".\\http\\*"]
switch_name              = "Default Switch"
output_directory         = "C:/ProgramData/Microsoft/Windows/Virtual Hard Disks/Images/packer-opnsense24/"
vlan_id                  = ""
ssh_username             = "root"
ssh_password             = "opnsense"
boot_command = [
  // https://github.com/niki-on-github/k3s-infra-playground/blob/05048024a1f4bda16629097073834b9f363943af/packer/opnsense/opnsense.pkr.hcl#L11
  // load config
  "<wait15><enter>",
  "<wait2>cd1<wait2><enter>",
  // auto config interface
  "<wait600>"
]
