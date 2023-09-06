# ref: https://www.nakivo.com/blog/how-to-disable-a-hyper-v-vm-stuck-in-the-starting-stopping-state/#:~:text=Method%203%3A%20Using%20PowerShell%20to%20kill%20the%20VM%20process
$VMName = "Dev-WinDevEval"
$VMGUID = get-vm $VMName | Select-Object -ExpandProperty Id  | Select-Object -ExpandProperty Guid 
$VMWMProc = (Get-WmiObject Win32_Process | Where-Object { $_.Name -match 'VMWP' -and $_.CommandLine -match $VMGUID }) 
Stop-Process ($VMWMProc.ProcessId) -Force