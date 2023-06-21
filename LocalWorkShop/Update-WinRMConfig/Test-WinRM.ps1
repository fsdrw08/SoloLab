$hostName=[System.Net.Dns]::GetHostName()
$winrmPort = "5986"

# Get the credentials of the machine
if (!$cert) {
    $cred = Get-Credential
  }

# Connect to the machine
$soptions = New-PSSessionOption -SkipCACheck -SkipCNCheck
Enter-PSSession -ComputerName $hostName -Port $winrmPort -Credential $cred -SessionOption $soptions -UseSSL