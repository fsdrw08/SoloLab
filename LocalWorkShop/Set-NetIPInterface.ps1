Get-NetIPInterface | Where-Object {$_.interfacealias -match "Internal Switch"} | ForEach-Object {
    Set-NetIPInterface -InterfaceIndex $_.ifIndex -AddressFamily IPv4,IPv6 -InterfaceMetric 9999 -Dhcp Disabled -WhatIf
    New-NetIPAddress -InterfaceIndex $_.ifIndex -AddressFamily IPv4 -IPAddress 192.168.255.2 -PrefixLength 24 -DefaultGateway 192.168.255.1
    # Remove-NetIPAddress -InterfaceIndex 5 -AddressFamily IPv4  
    # sudo Remove-NetRoute -InterfaceIndex 5 -Confirm:$false
    # New-NetIPAddress -InterfaceIndex 5 -AddressFamily IPv4 -IPAddress 192.168.255.2 -PrefixLength 24 -DefaultGateway 192.168.255.1
}
# Get-NetAdapter -Name "*internal switch*" | Set-NetAdapter -MacAddress "00-00-ba-be-fa-ce"