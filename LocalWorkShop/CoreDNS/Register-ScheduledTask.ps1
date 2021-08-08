$Execute = "$PSScriptRoot\runCoreDNS.bat"
$User= (whoami)

$Action = New-ScheduledTaskAction -Execute $Execute
$Trigger = New-ScheduledTaskTrigger -AtStartup
#$Trigger = New-ScheduledTaskTrigger -Once -At (get-date).AddSeconds(20); $Trigger.EndBoundary = (get-date).AddSeconds(120).ToString('s')
#$Setting = New-ScheduledTaskSettingsSet -StartWhenAvailable -DeleteExpiredTaskAfter 00:00:30
#Register-ScheduledTask -Force -user $User -TaskName "$user scueduled task" -Action $Action -Trigger $Trigger -Settings $Setting -CimSession $computer
Register-ScheduledTask -Force -user $User -TaskName "Start CoreDNS" -Trigger $Trigger -Action $Action 
