[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $SyncProfile,

    [Parameter()]
    [string]
    [ValidateSet(
        'C:/Users/Public/Downloads/bin',
        'D:/Users/Public/Downloads/bin'
    )]
    $LocalStore = 'C:/Users/Public/Downloads/bin',
        
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
    $PrivateRegistry = "https://dufs.day0.sololab",

    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $PrivateRegistryCredential = $(if ($Upload) {Get-Credential} else {$null})
)

$syncList = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath $SyncProfile)
# $repoDir = git rev-parse --show-toplevel
# $syncList = Get-Content -Path (Join-Path -Path $repoDir -ChildPath "LocalWorkShop\SyncTo-Dufs\Day1.jsonc")

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

# $localDir="$env:PUBLIC/Downloads/bin"
# $localDir="D:/Users/Public/Downloads/bin"
# $localDir="C:/Users/Public/Downloads/containers"
# $localDir="D:/Users/Public/Downloads/containers"
if (-not (Test-Path -Path $LocalStore)) {
    New-Item -ItemType Directory -Path $LocalStore -Force
}


## download
# $proxy="127.0.0.1:7890"
# $proxy="192.168.255.1:7890"
# $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy
if ($Download) {
    $syncList | ConvertFrom-Json | ForEach-Object {
        if ((-not (Test-Path -Path $LocalStore/$($_.archive))) -and $_.publicRegistry ) {
            $url="$($_.publicRegistry)/$($_.publicRepo)"
            $localPath="$LocalStore/$($_.archive)"
            Write-Host "Download $url to $localPath"
            curl.exe --output $localPath $url
        }
    }
}


## upload
$credential="$($PrivateRegistryCredential.UserName):$($PrivateRegistryCredential.GetNetworkCredential().Password)"
if ($Upload) {
    $proxy=""
    $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy

    $syncList | ConvertFrom-Json | ForEach-Object {
        if ($_.archive -and (Test-Path -Path $LocalStore/$($_.archive))) {
            # $privateDir="$($PrivateRegistry)/$(Split-Path -Path $_.privateRepo -Parent)"
            # Write-Host "Create directory $privateDir if not exit"
            # curl.exe -k -X MKCOL $privateDir --user $credential
            # ""
            $localPath="$LocalStore/$($_.archive)"
            $url="$($PrivateRegistry)/$($_.privateRepo)"
            Write-Host "Upload $localPath to $url"
            curl.exe -k -T $localPath $url --user $credential
            ""
        }
        Start-Sleep -Seconds 1
    }
}

