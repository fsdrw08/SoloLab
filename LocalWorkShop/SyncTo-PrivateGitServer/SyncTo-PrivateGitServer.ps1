[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $SyncProfile,

    [Parameter()]
    [string]
    [ValidateSet(
        'C:/Users/Public/Downloads/repos',
        'D:/Users/Public/Downloads/repos'
    )]
    $LocalStore='C:/Users/Public/Downloads/repos',
        
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
        "https://gitea.day4.sololab"
    )]
    $PrivateGitServer = "https://gitea.day4.sololab"

    # [ValidateNotNull()]
    # [System.Management.Automation.PSCredential]
    # [System.Management.Automation.Credential()]
    # $PrivateRegistryCredential = $(if ($Upload) {Get-Credential -Message "credential for private registry"} else {$null})
)

if (!(Get-Command git.exe)) {
    "Download git first"
    exit 1
}

$syncList = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath $SyncProfile)

## validate json
$referenceObject = @(
    "publicParentPath"
    "publicChildPath"
    "localChildPath"
    "privateChildPath"
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

if (-not (Test-Path -Path $LocalStore)) {
    New-Item -ItemType Directory -Path $LocalStore -Force
}


## pull
# $proxy="127.0.0.1:7890"
# $proxy="192.168.255.1:7890"
# $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy
if ($Download) {
    $syncList | ConvertFrom-Json | ForEach-Object {
        $publicParentPath = New-Object System.Uri("$($_.publicParentPath)")
        $publicFullUri = (New-Object System.Uri($publicParentPath, "$($_.publicChildPath)")).AbsoluteUri
        $localFullUri = (Join-Path -Path $LocalStore -ChildPath $_.localChildPath)
        if (-not (Test-Path -Path $localFullUri)) {
            Write-Host "git clone from $publicFullUri to $localFullUri"
            git clone $publicFullUri $localFullUri
        } else {
            Write-Host "$localFullUri already exists, pull latest"
            Set-Location $localFullUri
            git pull
            Set-Location $PSScriptRoot
        }
    }
}

## push
if ($Upload) {
    $proxy=$null
    $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy
    $syncList | ConvertFrom-Json | ForEach-Object {
        $privateParentPath = New-Object System.Uri($PrivateGitServer)
        $privateFullUri = (New-Object System.Uri($privateParentPath, "$($_.privateChildPath)")).AbsoluteUri
        $localFullUri = (Join-Path -Path $LocalStore -ChildPath $_.localChildPath)
        if (Test-Path -Path $localFullUri) {
            Write-Host "Push git repo $localFullUri to $($PrivateRegistry)/$($_.privateChildPath)"
            Set-Location $localFullUri
            git -c http.sslVerify=false push $privateFullUri
            git -c http.sslVerify=false push $privateFullUri --tags
            Set-Location $PSScriptRoot
        }
        Start-Sleep -Seconds 1
    }
}