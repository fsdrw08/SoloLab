@"
C:\Users\drw_0\Downloads\ISO\vyos-1.3.0-rc5-amd64.iso
C:\Users\drw_0\Downloads\ISO\AlmaLinux-8.4-x86_64-dvd.iso
"@ -split "`r`n" | ForEach-Object {
    # $_.lastindexof("\")
    $fileName = $_.substring($_.lastindexof("\") + 1,$_.length - $_.lastindexof("\") - 1)
    "$PSScriptRoot\$fileName"
    New-Item -ItemType HardLink -Path "$PSScriptRoot\$fileName" -target $_
}