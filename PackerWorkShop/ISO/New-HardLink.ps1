@"
$env:PUBLIC\Downloads\ISO\vyos-1.3.2-amd64.iso
$env:PUBLIC\Downloads\ISO\alpine-virt-3.17.0-x86_64.iso
$env:PUBLIC\Downloads\ISO\debian-11.6.0-amd64-netinst.iso
$env:PUBLIC\Downloads\ISO\openSUSE-Leap-Micro-5.2-DVD-x86_64-Build38.1-Media.iso
$env:PUBLIC\Downloads\ISO\Fedora-Server-dvd-x86_64-38-1.6.iso
$env:PUBLIC\Downloads\ISO\Fedora-Server-netinst-x86_64-38-1.6.iso
"@ -split "`r`n" | ForEach-Object {
    # $_.lastindexof("\")
    if (Test-Path $_) {
        $fileName = $_.substring($_.lastindexof("\") + 1, $_.length - $_.lastindexof("\") - 1)
        $fileName
        if (-not (Test-Path "$PSScriptRoot\$fileName")) {
            New-Item -ItemType HardLink -Path "$PSScriptRoot\$fileName" -target $_
        }
    }
    
}