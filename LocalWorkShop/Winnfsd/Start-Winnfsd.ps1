$NFSSharePath = "$env:PUBLIC\documents\db"

if (!(Test-Path $NFSSharePath)) {
    New-Item -ItemType Directory -Path $NFSSharePath
}

$IP = Get-NetAdapter | Where-Object {$_.Name -like "*Internal Switch*"} | Get-NetIPAddress `
        | Where-Object {$_.addressfamily -eq "IPv4"} | Select-Object -ExpandProperty ipaddress

. winnfsd.exe -addr $IP $NFSSharePath /exports