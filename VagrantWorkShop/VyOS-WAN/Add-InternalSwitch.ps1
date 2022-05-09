#powershell.exe -ExecutionPolicy bypass -command \"get-vm -Name `\"vyos*`\" | Add-VMNetworkAdapter -SwitchName 'Default Switch'\"
if (![bool](Get-VMSwitch | Where-Object {$_.name -eq "internal switch"})) {
    New-VMSwitch -Name "Internal Switch" -SwitchType Internal
}
get-vm -Name "vyos*" | Add-VMNetworkAdapter -SwitchName 'Internal Switch'