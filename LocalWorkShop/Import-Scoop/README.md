### export a list of scoop bucket and app
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="LocalWorkShop/Import-Scoop"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
scoop export > scoop.json
```

### import
```powershell
scoop import scoop.json
```
