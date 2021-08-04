@"
C:\Users\drw_0\Downloads\ISO\vyos-1.3.0-rc5-amd64.iso
C:\Users\drw_0\Downloads\ISO\AlmaLinux-8.4-x86_64-dvd.iso
C:\Users\drw_0\Downloads\ISO\ubuntu-20.04.2-live-server-amd64.iso
C:\Users\drw_0\Downloads\ISO\alpine-standard-3.14.0-x86_64.iso
"@ -split "`r`n" | ForEach-Object {
    # $_.lastindexof("\")
    if (Test-Path $_) {
        $fileName = $_.substring($_.lastindexof("\") + 1,$_.length - $_.lastindexof("\") - 1)
        if (-not (Test-Path "$PSScriptRoot\$fileName")) {
            New-Item -ItemType HardLink -Path "$PSScriptRoot\$fileName" -target $_
        }
    }
    
}