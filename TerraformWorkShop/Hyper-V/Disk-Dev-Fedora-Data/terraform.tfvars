provider_hyperv = {
  user     = "root"
  password = "P@ssw0rd"
  host     = "127.0.0.1"
  port     = 5986
}

vhd = {
  path       = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Data_Disk\\Dev-Fedora-DataDisk.vhdx"
  block_size = 0
  type       = "dynamic"
  size       = 42949672960
}
