### Deploy PostgreSQL nomad job
[TerraformWorkShop/Nomad/Jobs/postgresql/](../../TerraformWorkShop/Nomad/Jobs/postgresql/)
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="TerraformWorkShop/Nomad/Jobs/postgresql/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
sudo pwsh.exe -c "[System.Environment]::SetEnvironmentVariable('CONSUL_HTTP_TOKEN',`"$env:CONSUL_HTTP_TOKEN`"); terraform init -upgrade"; 
terraform apply --auto-approve
``` 