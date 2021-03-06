@"
$env:USERPROFILE\Downloads\ISO\vyos-1.3.0-epa3-amd64.iso
$env:USERPROFILE\Downloads\ISO\alpine-virt-3.16.1-x86_64.iso
$env:USERPROFILE\Downloads\ISO\debian-11.3.0-amd64-netinst.iso
$env:USERPROFILE\Downloads\ISO\openSUSE-Leap-Micro-5.2-DVD-x86_64-Build38.1-Media.iso
$env:USERPROFILE\Downloads\ISO\openSUSE-Leap-15.4-DVD-x86_64-Build243.2-Media.iso
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