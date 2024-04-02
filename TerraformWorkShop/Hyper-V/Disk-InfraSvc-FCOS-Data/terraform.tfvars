hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

vhd_count = 1

vhd = {
  dir        = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Data_Disk"
  basename   = "InfraSvc-FCOS-Data.vhdx"
  block_size = 0
  type       = "dynamic"
  size       = 42949672960
}
