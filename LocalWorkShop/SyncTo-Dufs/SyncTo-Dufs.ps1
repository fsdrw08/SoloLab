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
    $PrivateRegistry = "https://dufs.day0.sololab",

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
# $syncList = Get-Content -Path (Join-Path -Path $repoDir -ChildPath "LocalWorkShop\SyncTo-Dufs\Day1.jsonc")

## validate json
$referenceObject = @(
    "type"
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

if (-not (Test-Path -Path $LocalStore)) {
    New-Item -ItemType Directory -Path $LocalStore -Force
}


## download
if ($Download) {
    $syncList | ConvertFrom-Json | ForEach-Object {
        if ((-not (Test-Path -Path $LocalStore/$($_.archive))) -and $_.publicRegistry ) {
            $baseUri = New-Object System.Uri("$($_.publicRegistry)")
            $relativeUri = New-Object System.Uri($baseUri, "$($_.publicRepo)")
            $fullUri=$relativeUri.AbsoluteUri

            $localPath="$LocalStore/$($_.archive)"
            $data = $_.data

            switch ($_.type) {
                "general" { 
                    Write-Host "Download $fullUri to $localPath"
                    curl.exe --output $localPath --location $fullUri
                }
                "vault-kvv2" {
                    if ($VaultToken -ne "") {
                        Write-Host "From $fullUri Fetch `"$data`" Save to $localPath"
                        $content = $(curl.exe `
                            -k -s `
                            -H "X-Vault-Token: $VaultToken" `
                            -X GET `
                            $fullUri | jq.exe "$data")
                        Set-Content -Path $localPath -Value $content.Replace('"','').Replace('\n',"`r`n")
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
        if ($_.archive -and (Test-Path -Path $LocalStore/$($_.archive))) {
            # $privateDir="$($PrivateRegistry)/$(Split-Path -Path $_.privateRepo -Parent)"
            # Write-Host "Create directory $privateDir if not exit"
            # curl.exe -k -X MKCOL $privateDir --user $credential
            # ""
            $localPath="$LocalStore/$($_.archive)"
            
            $baseUri = New-Object System.Uri("$PrivateRegistry")
            $relativeUri = New-Object System.Uri($baseUri, "$($_.privateRepo)")
            $fullUri=$relativeUri.AbsoluteUri

            Write-Host "Upload $localPath to $fullUri"
            curl.exe -k -T $localPath $fullUri --user $credential
            if ($_.type -eq "vault-kvv2") {
                Write-Host "Remove sensitive data file $localPath"
                Remove-Item -Path $localPath -Force
            }
            ""
        }
        Start-Sleep -Seconds 1
    }
}

