ref: 
[Setting up a Windows Host](https://docs.ansible.com/ansible/latest/os_guide/windows_setup.html)
[ConfigureRemotingForAnsible.ps1](https://github.com/ansible/ansible/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1)
[Check if you can connect to WinRM](https://github.com/taliesins/terraform-provider-hyperv#:~:text=Check%20if%20you%20can%20connect%20to%20WinRM)
copy and run the path of `Update-WinRMConfig.bat` in this dir, and have a check
```powershell
winrm get winrm/config/Service

# To view the current listeners that are running on the WinRM service:
winrm enumerate winrm/config/Listener
```
or copy and run the path of `Test-WinRM.bat` in this dir to test the winrm connect.