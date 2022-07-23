Get-ChildItem -Recurse | Where-Object {$_.Name -like "*.sh" -or $_.Name -like "*.yaml" } | `
    Select-Object -ExpandProperty VersionInfo | `
    Select-Object -ExpandProperty filename | `
    ForEach-Object { 
        dos2unix.exe $_ 
    }