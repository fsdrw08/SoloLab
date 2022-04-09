Get-NetIPInterface | Where-Object {$_.interfacealias -match "Internal Switch"} | ForEach-Object {
    Set-NetIPInterface -InterfaceIndex $_.ifIndex -InterfaceMetric 9999 -Dhcp Disabled -AddressFamily IPv4,IPv6 -WhatIf
}
Get-NetAdapter -Name "*internal switch*" | Set-NetAdapter -MacAddress "00-00-ba-be-fa-ce"