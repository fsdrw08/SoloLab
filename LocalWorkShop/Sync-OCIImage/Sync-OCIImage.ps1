$repoDir = git rev-parse --show-toplevel
$syncList = Get-Content -Path (Join-Path -Path $repoDir -ChildPath "LocalWorkShop\Sync-OCIImage\Day0.jsonc")
# $syncList = Get-Content -Path (Join-Path -Path $repoDir -ChildPath "LocalWorkShop\Sync-OCIImage\Day1.jsonc")
# $syncList = Get-Content -Path (Join-Path -Path $repoDir -ChildPath "LocalWorkShop\Sync-OCIImage\Day2.jsonc")

$localDir="$env:PUBLIC/Downloads/containers"
# $localDir="C:/Users/Public/Downloads/containers"
# $localDir="D:/Users/Public/Downloads/containers"
if (-not (Test-Path -Path $localDir)) {
    New-Item -ItemType Directory -Path $localDir -Force
}


$proxy="127.0.0.1:7890"
# $proxy="192.168.255.1:7890"
$env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy

$syncList | ConvertFrom-Json | ForEach-Object {
    if (-not (Test-Path -Path $localDir/$($_.archive))) {
        Write-Host "Download docker image then convert to OCI archive $localDir/$($_.archive)"
        skopeo copy --insecure-policy `
            --override-os=linux `
            --override-arch=amd64 `
            docker://$($_.publicRegistry)/$($_.publicRepo) `
            oci-archive:$localDir/$($_.archive)
    }
}

$proxy=""
$env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy

$syncList | ConvertFrom-Json | ForEach-Object {
    if (Test-Path -Path $localDir/$($_.archive)) {
    Write-Host "Upload OCI image OCI archive $localDir/$($_.archive) to $($_.privateRegistry)/$($_.privateRepo)"
    skopeo copy --insecure-policy `
        --dest-tls-verify=false `
        --dest-creds="admin:P@ssw0rd" `
        oci-archive:$localDir/$($_.archive) `
        docker://$($_.privateRegistry)/$($_.privateRepo)
    }
    Start-Sleep -Seconds 1
}