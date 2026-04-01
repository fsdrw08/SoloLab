[CmdletBinding()]
param (
  [Parameter()]
  [ValidateSet('1130','1150','1160','1240','1340')]
  [string]
  $OSVersion,

  [Parameter()]
  [ValidateSet(
    'vagrant'
  )]
  [string]
  $except=$null
)

#Verify the pre-request
@"
packer
oscdimg
"@ -split "`r`n" | ForEach-Object {
  if (-not (Get-Command $_)) {
    [bool]$Ready = $false
  }
  $Ready
}

# Build images
if ($Ready -ne $false) {

  # Get Start Time
  $startDTM = (Get-Date)
  
  # Variables
  $var_file = "$PSScriptRoot\vars_debian$OSVersion.pkrvars.hcl"
  $machine = "Debian $OSVersion-g2"
  $packer_log = 0
  
  if (Test-Path -Path "$var_file") {
    Write-Output "var file found"
    Write-Output "Building: $machine"
    $currentLocation = (Get-Location).Path
    Set-Location $PSScriptRoot
    try {
      $env:PACKER_LOG = $packer_log
      packer validate -var-file="$var_file" .
    }
    catch {
      Write-Output "Packer validation failed, exiting."
      exit (-1)
    }
    try {
      # Convert dos format to unix format
      # "dos2unix"
      # Get-ChildItem -Path $PSScriptRoot -Recurse `
      #   | Where-Object {$_.Name -like "*.sh" -or $_.Name -eq "answers"} `
      #   | Select-Object -ExpandProperty VersionInfo `
      #   | Select-Object -ExpandProperty filename `
      #   | ForEach-Object {
      #     #[io.file]::WriteAllText($_, ((Get-Content -Raw  $_) -replace "`r`n","`n"))
      #     dos2unix $_
      #   }
      
      $env:PACKER_LOG = $packer_log
      packer version
      if ($null -ne $except) {
        packer build --force -var-file="$var_file" --except=$except .
      } else {
        packer build --force -var-file="$var_file" .
      }
    }
    catch {
      Write-Output "Packer build failed, exiting."
      exit (-1)
    }
    Set-Location $currentLocation
  }
  else {
    Write-Output "Template or var file not found - exiting"
    exit (-1)
  }
}
else {
  "seems packer is not ready"
}

$endDTM = (Get-Date)
Write-Host "[INFO]  - Elapsed Time: $(($endDTM - $startDTM).TotalSeconds) seconds" -ForegroundColor Yellow
