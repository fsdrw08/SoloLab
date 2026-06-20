Render atlantis repo level config file
```powershell
$repoDir = git rev-parse --show-toplevel
$childPath = "atlantis.tmpl.yaml"

$templatePath = Join-Path -Path $repoDir -ChildPath $childPath
$resultPath = Join-Path -Path $repoDir -ChildPath "atlantis.yaml"
Set-Location -Path $repoDir
gomplate.exe -f $templatePath -o $resultPath
```