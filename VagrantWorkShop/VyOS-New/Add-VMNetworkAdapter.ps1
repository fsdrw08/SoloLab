[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $VMName
)
#powershell.exe -ExecutionPolicy bypass -command \"get-vm -Name `\"vyos*`\" | Add-VMNetworkAdapter -SwitchName 'Default Switch'\"
Get-VM -Name $VMName | Add-VMNetworkAdapter -SwitchName 'Internal Switch'
