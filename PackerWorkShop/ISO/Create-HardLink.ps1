@"
$env:USERPROFILE\Downloads\ISO\vyos-1.3.0-rc6-amd64.iso
$env:USERPROFILE\Downloads\ISO\AlmaLinux-8.4-x86_64-dvd.iso
$env:USERPROFILE\Downloads\ISO\ubuntu-20.04.2-live-server-amd64.iso
$env:USERPROFILE\Downloads\ISO\alpine-virt-3.14.2-x86_64.iso
$env:USERPROFILE\Downloads\ISO\debian-10.10.0-amd64-DVD-1.iso
$env:USERPROFILE\Downloads\ISO\openSUSE-Tumbleweed-DVD-x86_64-Snapshot20210810-Media.iso
$env:USERPROFILE\Downloads\ISO\debian-11.0.0-amd64-netinst.iso
$env:USERPROFILE\Downloads\ISO\fedora-coreos-34.20210808.3.0-live.x86_64.iso
$env:USERPROFILE\Downloads\ISO\Fedora-Server-dvd-x86_64-34-1.2.iso
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