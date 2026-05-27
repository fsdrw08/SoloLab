[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $SyncProfile,

    [Parameter()]
    [string]
    [ValidateSet(
        'C:/Users/Public/Downloads',
        'D:/Users/Public/Downloads'
    )]
    $LocalParentPath = 'C:/Users/Public/Downloads',
        
    [Parameter()]
    [bool]
    [ValidateSet(
        $true,
        $false
    )]
    $Download=$true,
        
    # Parameter help description
    [Parameter()]
    [string]
    $VaultToken = $(if (
        (
            (Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath $SyncProfile) `
                | ConvertFrom-Json | Select-Object -ExpandProperty "type" -Unique
            ) -contains "vault-kvv2"
        ) `
        -and (
            $Download -eq $true
        )
    ){
        Read-Host "Require vault token to get cert content"
    }),

    [Parameter()]
    [bool]
    [ValidateSet(
        $true,
        $false
    )]
    $Upload=$true,

    [Parameter()]
    [string]
    $PrivateRegistry = "https://dufs.day1.sololab",

    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $PrivateRegistryCredential = $(if ($Upload) {Get-Credential -Message "dufs credential"} else {$null})
)

@("curl", "jq") | ForEach-Object {
    if (!(Get-Command $_)) {
        "Download/Install $_ first"
        exit 1
    }
}

$syncList = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath $SyncProfile)

# $repoDir = git rev-parse --show-toplevel
# $syncList = Get-Content -Path (Join-Path -Path $repoDir -ChildPath "LocalWorkShop\SyncTo-Dufs\Day2.jsonc")

## validate json
$referenceObject = @(
    "type"
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

if (-not (Test-Path -Path $localParentPath)) {
    New-Item -ItemType Directory -Path $localParentPath -Force
}


## download
if ($Download) {
    $syncList | ConvertFrom-Json | ForEach-Object {
        if ((-not (Test-Path -Path $localParentPath/$($_.localChildPath))) -and $_.publicParentPath ) {
            $publicParentPath = New-Object System.Uri("$($_.publicParentPath)")
            $publicFullUri = (New-Object System.Uri($publicParentPath, "$($_.publicChildPath)")).AbsoluteUri

            $localFullPath="$localParentPath/$($_.localChildPath)"
            $data = $_.data

            switch ($_.type) {
                "general" { 
                    Write-Host "Download $publicFullUri to $localFullPath"
                    curl.exe --output $localFullPath --location $publicFullUri
                }
                "vault-kvv2" {
                    if ($VaultToken -ne "") {
                        Write-Host "From $publicFullUri Fetch `"$data`" Save to $localFullPath"
                        $content = $(curl.exe `
                            -k -s `
                            -H "X-Vault-Token: $VaultToken" `
                            -X GET `
                            $publicFullUri | jq.exe "$data")
                        Set-Content -Path $localFullPath -Value $content.Replace('"','').Replace('\n',"`r`n")
                    } else {
                        Write-Host "`$VaultToken empty, skip fetch from vault"
                    }
                }
                Default {}
            }
        }
    }
}


## upload
if ($Upload) {
    $credential="$($PrivateRegistryCredential.UserName):$($PrivateRegistryCredential.GetNetworkCredential().Password)"

    $syncList | ConvertFrom-Json | ForEach-Object {
        if ($_.localChildPath -and (Test-Path -Path $localParentPath/$($_.localChildPath))) {
            $localFullPath="$localParentPath/$($_.localChildPath)"
            
            $privateParentPath = New-Object System.Uri("$PrivateRegistry")
            $privateChildPath = $_.privateChildPath
            
            switch ($_.type) {
                "general" { 
                    $privateFullUri = (New-Object System.Uri($privateParentPath, "$privateChildPath")).AbsoluteUri
                    
                    Write-Host "Upload $localFullPath to $privateFullUri"
                    curl.exe -k -T $localFullPath $privateFullUri --user $credential
                }
                "vault-kvv2" {
                    $privateFullUri = (New-Object System.Uri($privateParentPath, "$privateChildPath")).AbsoluteUri

                    Write-Host "Upload $localFullPath to $privateFullUri"
                    curl.exe -k -T $localFullPath $privateFullUri --user $credential

                    Write-Host "Remove sensitive data file $localFullPath"
                    Remove-Item -Path $localFullPath -Force
                }
                "terraform-mirror" {
                    Get-ChildItem -Path $localFullPath -Recurse | ForEach-Object {
                        if (-not (Get-Item -Path $_.FullName).PSIsContainer) {
                            $TFProviderPath = (New-Object System.Uri($_.FullName)).AbsolutePath.Replace("$localFullPath/","")
                            $privateFullUri = (New-Object System.Uri($privateParentPath, "$privateChildPath/$TFProviderPath")).AbsoluteUri
                        
                            Write-Host "Upload $($_.FullName) to $privateFullUri `r`n"
                            curl.exe -k -T $($_.FullName) $privateFullUri --user $credential
                        }
                    }
                }
                Default {}
            }            
            ""
        }
        Start-Sleep -Seconds 1
    }
}

