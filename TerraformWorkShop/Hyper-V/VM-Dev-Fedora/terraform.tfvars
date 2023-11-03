provider_hyperv = {
  user     = "root"
  password = "P@ssw0rd"
  host     = "127.0.0.1"
  port     = 5986
}

vm_name        = "Dev-Fedora"
source_disk    = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\output-fedora38-base\\Virtual Hard Disks\\packer-fedora38-g2.vhdx"
data_disk_path = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Data_Disk\\Dev-Fedora-DataDisk.vhdx"
