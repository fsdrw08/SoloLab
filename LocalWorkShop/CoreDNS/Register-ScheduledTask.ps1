$User= "NT AUTHORITY\SYSTEM"
$Principal = New-ScheduledTaskPrincipal -UserID $User -LogonType ServiceAccount

$Action = New-ScheduledTaskAction -Execute CoreDNS.exe -Argument "-conf $PSScriptRoot\Corefile"
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries 
#$Trigger = New-ScheduledTaskTrigger -Once -At (get-date).AddSeconds(20); $Trigger.EndBoundary = (get-date).AddSeconds(120).ToString('s')
#$Setting = New-ScheduledTaskSettingsSet -StartWhenAvailable -DeleteExpiredTaskAfter 00:00:30
#Register-ScheduledTask -Force -user $User -TaskName "$user scueduled task" -Action $Action -Trigger $Trigger -Settings $Setting -CimSession $computer
Register-ScheduledTask -TaskName "Start CoreDNS" -Trigger $Trigger -Action $Action -Principal $Principal -Settings $Settings
