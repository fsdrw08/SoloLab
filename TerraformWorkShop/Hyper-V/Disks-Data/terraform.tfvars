prov_hyperv = {
  host     = "127.0.0.1"
  port     = 5986
  user     = "root"
  password = "P@ssw0rd"
}

vhds = [
  {
    path       = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Data_Disk\\Day0-FCOS.vhdx"
    block_size = 0
    type       = "Dynamic"
    size       = 128849018880
  },
  {
    path       = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Data_Disk\\Day1-FCOS.vhdx"
    block_size = 0
    type       = "Dynamic"
    size       = 42949672960
  },
  # {
  #   path       = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Data_Disk\\Day0-FCOS01.vhdx"
  #   block_size = 0
  #   type       = "Dynamic"
  #   size       = 42949672960
  # },
  # {
  #   path       = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\Data_Disk\\Day0-FCOS02.vhdx"
  #   block_size = 0
  #   type       = "Dynamic"
  #   size       = 42949672960
  # },
]
