0. (Optional)Link `$env:PUBLIC\Downloads\ISO\` to other path:
```powershell
$launchPath="C:\Users\Public\Downloads"
$targetPath="D:\Users\Public\Downloads"

if (-not (Test-Path -Path $launchPath)) {
   New-Item -ItemType Junction `
   -Value $targetPath $launchPath
} else {
   "`"$launchPath`" already exist"
}
```
1. Download related ISO to `$env:PUBLIC\Downloads\ISO\` 
   VYOS: https://vyos.net/get/nightly-builds/  
   Alpine Linux: https://www.alpinelinux.org/downloads/
2. Run script [.\New-HardLink.bat](Create-HardLink.ps1) to create ISO hard link from `$env:USERPROFILE\Downloads\ISO\` to this folder