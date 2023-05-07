ref: 
[Setting up a Windows Host](https://docs.ansible.com/ansible/latest/os_guide/windows_setup.html)
[ConfigureRemotingForAnsible.ps1](https://github.com/ansible/ansible/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1)

copy and run the path of ps1 in this dir, and have a check
```powershell
winrm get winrm/config/Service

# To view the current listeners that are running on the WinRM service:
winrm enumerate winrm/config/Listener
```