$repoDir = git rev-parse --show-toplevel
$syncList = Get-Content -Path (Join-Path -Path $repoDir -ChildPath "LocalWorkShop\Sync-Binaries\Day2.jsonc")
# $syncList = Get-Content -Path (Join-Path -Path $repoDir -ChildPath "LocalWorkShop\Sync-Binaries\Day1.jsonc")

$localDir="$env:PUBLIC/Downloads/bin"
# $localDir="C:/Users/Public/Downloads/containers"
# $localDir="D:/Users/Public/Downloads/containers"
if (-not (Test-Path -Path $localDir)) {
    New-Item -ItemType Directory -Path $localDir -Force
}


$proxy="127.0.0.1:7890"
# $proxy="192.168.255.1:7890"
$env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy

$syncList | ConvertFrom-Json | ForEach-Object {
    if ((-not (Test-Path -Path $localDir/$($_.archive))) -and $_.publicRegistry ) {
        $url="$($_.publicRegistry)/$($_.publicRepo)"
        $localPath="$localDir/$($_.archive)"
        Write-Host "Download $url to $localPath"
        curl.exe --output $localPath $url
    }
}

$proxy=""
$env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy

# curl -k -X MKCOL https://dufs.day0.sololab/binaries --user admin:admin
$credential="admin:admin"

$syncList | ConvertFrom-Json | ForEach-Object {
    if ($_.archive -and (Test-Path -Path $localDir/$($_.archive))) {
        $localPath="$localDir/$($_.archive)"
        $url="$($_.privateRegistry)/$($_.privateRepo)"
        $privateDir="$($_.privateRegistry)/$(Split-Path -Path $url -Parent)"
        Write-Host "Create directory $privateDir if not exit"
        curl -k -X MKCOL $privateDir --user $credential
        Write-Host "Upload $localPath to $url"
        curl -k -T $localPath $url --user $credential
        ""
    }
    Start-Sleep -Seconds 1
}