[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $SyncProfile,
    
    [Parameter()]
    [ValidateSet(
        'C:/Users/Public/Downloads/containers/trivy',
        'D:/Users/Public/Downloads/containers/trivy'
    )]
    [string]
    $LocalStore='C:/Users/Public/Downloads/containers/trivy',
        
    [Parameter()]
    [bool]
    [ValidateSet(
        $true,
        $false
    )]
    $Download=$true,
        
    [Parameter()]
    [bool]
    [ValidateSet(
        $true,
        $false
    )]
    $Upload=$true,

    [Parameter()]
    [string]
    [ValidateSet(
        "zot.vyos.sololab.dev",
        "zot.day0.sololab"
    )]
    $PrivateRegistry = "zot.vyos.sololab.dev",
        
    [Parameter()]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $PrivateRegistryCredential = $(if ($Upload) {Get-Credential} else {$null})
)

if (!(Get-Command oras.exe)) {
    "Download oras first"
    exit 1
}

$syncList = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath $SyncProfile)
# $repoDir = git rev-parse --show-toplevel
# $syncList = Get-Content -Path (Join-Path -Path $repoDir -ChildPath "LocalWorkShop\Sync-OCIImage\VyOS-Trivy.jsonc")
# $syncList = Get-Content -Path (Join-Path -Path $repoDir -ChildPath "LocalWorkShop\Sync-OCIImage\Day0-Trivy.jsonc")

## validate json
$referenceObject = @(
    "publicRegistry"
    "publicRepo"
    "archive"
    "ociFileMediaType"
    "privateRepo"
    "manifestFile"
    )
$syncList | ConvertFrom-Json | ForEach-Object {
    $differenceObject = $_ | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty name 
    $compareResult = Compare-Object -ReferenceObject $referenceObject -DifferenceObject $differenceObject
    if ($compareResult -ne $null ) {
        $resultDetail = $compareResult | Select-Object -ExpandProperty SideIndicator
        if ($resultDetail -eq "<=") {
            $_
            $compareResult
            Write-Host "validate the sync profile, <= means attribute missed, => means something not required, but it's fine to keep"
            exit 1
        }
    }
}

## ensuer dir exist
# $LocalStore = "$env:PUBLIC/Downloads/containers/trivy"
# $LocalStore="D:/Users/Public/Downloads/containers"
if (-not (Test-Path $LocalStore)) {
    New-Item -ItemType Directory -Path $LocalStore -Force
}
$currentLocation=Get-Location | Select-Object -ExpandProperty Path


## pull
## https://github.com/LubinLew/trivy-data-sync/blob/80befc585f54769cfd28cd28fc8d9e541ca4fbee/trivy_sync.sh#L112
# $proxy="127.0.0.1:7890"
# $proxy="192.168.255.1:7890"
# $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy
if ($Download) {
    $syncList | ConvertFrom-Json | ForEach-Object {
        # if (-not (Test-Path -Path $LocalStore/$($_.archive))) {
            "go to local oci archive dir"
            Set-Location -Path $LocalStore
            oras pull "$($_.publicRegistry)/$($_.publicRepo)"
            
            # Download manifest
            oras manifest fetch `
            --output $_.ManifestFile `
            "$($_.publicRegistry)/$($_.publicRepo)"
        # }
    }
}

## push
$proxy=$null
$env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy
if ($Upload) {
   
    # Push the prior downloaded trivy-db to private registry
    # https://github.com/aquasecurity/trivy-db/blob/8c398f13db0ed9be333fe1b9ddab158ab7262967/README.md#building-the-db
    
    $trivyArtifactType = "application/vnd.aquasec.trivy.config.v1+json"
    $syncList | ConvertFrom-Json | ForEach-Object {
        if (Test-Path -Path $LocalStore/$($_.archive)) {
            "login to zot"
            oras login --insecure `
                --username $($PrivateRegistryCredential.UserName) `
                --password $($PrivateRegistryCredential.GetNetworkCredential().Password) `
                $PrivateRegistry
            
            "oras push"
            $artifactPath = Join-Path -Path $LocalStore -ChildPath $_.archive
            oras push `
                --insecure `
                --disable-path-validation `
                --artifact-type $trivyArtifactType `
                "$($PrivateRegistry)/$($_.privateRepo)" `
                "$($artifactPath):$($_.ociFileMediaType)"
            
            "oras manifest push"
            $manifestFilePath = Join-Path -Path $LocalStore -ChildPath $_.manifestFile
            oras manifest push `
                --insecure `
                "$($PrivateRegistry)/$($_.privateRepo)" `
                $manifestFilePath
            
            "oras manifest fetch"
            oras manifest fetch --insecure "$($PrivateRegistry)/$($_.privateRepo)"
        }
    }
}
Set-Location -Path $currentLocation