### export a list of scoop bucket and app
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="LocalWorkShop/Import-Scoop"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
scoop export > scoop.json
```

### config scoop proxy
```powershell
scoop config proxy 127.0.0.1:7890
```

### import
```powershell
scoop import scoop.json
```
