run packer init to download plugin
```powershell
$env:HTTP_PROXY="127.0.0.1:7890" 
$env:HTTPS_PROXY="127.0.0.1:7890"
packer init ./
```