resource "hyperv_vhd" "InfraSvc-Data" {
  path       = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\InfraSvc-OpenSUSE_Leap-Data\\InfraSvc-OpenSUSE_Leap-Data.vhdx"
  vhd_type   = "Dynamic"
  size       = 42949672960 #40GB
  block_size = 0

}
