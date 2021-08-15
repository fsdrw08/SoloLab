@"
C:\Users\drw_0\Downloads\ISO\vyos-1.3.0-rc5-amd64.iso
C:\Users\drw_0\Downloads\ISO\AlmaLinux-8.4-x86_64-dvd.iso
C:\Users\drw_0\Downloads\ISO\ubuntu-20.04.2-live-server-amd64.iso
C:\Users\drw_0\Downloads\ISO\alpine-virt-3.14.1-x86_64.iso
C:\Users\drw_0\Downloads\ISO\debian-10.10.0-amd64-DVD-1.iso
C:\Users\drw_0\Downloads\ISO\openSUSE-Tumbleweed-DVD-x86_64-Snapshot20210810-Media.iso
C:\Users\drw_0\Downloads\ISO\debian-live-11.0.0-amd64-standard.iso
"@ -split "`r`n" | ForEach-Object {
    # $_.lastindexof("\")
    if (Test-Path $_) {
        $fileName = $_.substring($_.lastindexof("\") + 1,$_.length - $_.lastindexof("\") - 1)
        $fileName
        if (-not (Test-Path "$PSScriptRoot\$fileName")) {
            New-Item -ItemType HardLink -Path "$PSScriptRoot\$fileName" -target $_
        }
    }
    
}