[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $SyncProfile,

    [Parameter()]
    [string]
    [ValidateSet(
        'C:/Users/Public/Downloads/containers',
        'D:/Users/Public/Downloads/containers'
    )]
    $LocalStore='C:/Users/Public/Downloads/containers',
        
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

    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $PrivateRegistryCredential = $(if ($Upload) {Get-Credential -Message "credential for private registry"} else {$null})
)

if (!(Get-Command skopeo.exe)) {
    "Download skopeo first"
    exit 1
}

$syncList = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath $SyncProfile)

## validate json
$referenceObject = @(
    "publicRegistry"
    "publicRepo"
    "archive"
    "privateRepo"
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

# $LocalStore="$env:PUBLIC/Downloads/containers"
# $LocalStore="C:/Users/Public/Downloads/containers"
# $LocalStore="D:/Users/Public/Downloads/containers"
if (-not (Test-Path -Path $LocalStore)) {
    New-Item -ItemType Directory -Path $LocalStore -Force
}


## pull
# $proxy="127.0.0.1:7890"
# $proxy="192.168.255.1:7890"
# $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy
if ($Download) {
    $syncList | ConvertFrom-Json | ForEach-Object {
        if (-not (Test-Path -Path $LocalStore/$($_.archive))) {
            Write-Host "Download docker image then convert to OCI archive $LocalStore/$($_.archive)"
            skopeo copy --insecure-policy `
                --override-os=linux `
                --override-arch=amd64 `
                docker://$($_.publicRegistry)/$($_.publicRepo) `
                oci-archive:$LocalStore/$($_.archive)
        }
    }
}

## push
if ($Upload) {
    # $proxy=$null
    # $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy
    $syncList | ConvertFrom-Json | ForEach-Object {
        if (Test-Path -Path $LocalStore/$($_.archive)) {
            Write-Host "Upload OCI image OCI archive $LocalStore/$($_.archive) to $($PrivateRegistry)/$($_.privateRepo)"
            skopeo copy --insecure-policy `
                --dest-tls-verify=false `
                --dest-creds="$($PrivateRegistryCredential.UserName):$($PrivateRegistryCredential.GetNetworkCredential().Password)" `
                oci-archive:$LocalStore/$($_.archive) `
                docker://$($PrivateRegistry)/$($_.privateRepo)
        }
        Start-Sleep -Seconds 1
    }
}