# $hostName=[System.Net.Dns]::GetHostName()
$hostName = "127.0.0.1"
$winrmPort = "5986"

# Get the credentials of the machine
if (!$cred) {
  $cred = Get-Credential
}

# Connect to the machine
$soptions = New-PSSessionOption -SkipCACheck -SkipCNCheck
Enter-PSSession -ComputerName $hostName -Port $winrmPort -Credential $cred -SessionOption $soptions -UseSSL
# $s = New-PSSession -ComputerName $hostName
# Enter-PSSession -Session $s -Credential $cred