@REM https://stackoverflow.com/questions/19335004/how-to-run-a-powershell-script-from-a-batch-file
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0\ConfigureRemotingForAnsible.ps1""' -Verb RunAs -Verbose}"


PAUSE