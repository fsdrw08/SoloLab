[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $VMName
)
#powershell.exe -ExecutionPolicy bypass -command \"get-vm -Name `\"vyos*`\" | Add-VMNetworkAdapter -SwitchName 'Default Switch'\"

if (!(Get-VMNetworkAdapter -VMName $VMName | Where-Object {$_.SwitchName -eq "Default Switch"})) {
    Get-VM -Name $VMName | Add-VMNetworkAdapter -SwitchName 'Default Switch'
}

if (!(Get-VMNetworkAdapter -VMName $VMName | Where-Object {$_.SwitchName -eq "Internal Switch"})) {
    Get-VM -Name $VMName | Add-VMNetworkAdapter -SwitchName 'Internal Switch'
}
