#powershell.exe -ExecutionPolicy bypass -command \"get-vm -Name `\"vyos*`\" | Add-VMNetworkAdapter -SwitchName 'Default Switch'\"
get-vm -Name "vyos*" | Add-VMNetworkAdapter -SwitchName 'Internal Switch'