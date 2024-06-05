$currentDirectory = (Get-Location).Path

Get-ChildItem -Path $currentDirectory -Recurse -Exclude "*.tgz" | where-object {$_.Mode -eq "-a---"} `
| Select-Object -ExpandProperty VersionInfo `
| Select-Object -ExpandProperty filename `
| ForEach-Object {
   dos2unix $_
   $currentDirectory
}