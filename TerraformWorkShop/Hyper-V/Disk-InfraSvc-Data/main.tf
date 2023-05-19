resource "hyperv_vhd" "InfraSvc-Data" {
  path       = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\InfraSvc-Data\\InfraSvc-Data.vhdx"
  vhd_type   = "Dynamic"
  size       = 21474836480 #20GB
  block_size = 0

}
