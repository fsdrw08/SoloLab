[CmdletBinding()]
param (
  [Parameter()]
  [ValidateSet(
    '13x', 
    '14x', 
    '13x-cloudinit', 
    '14x-cloudinit', 
    '14x-cloudinit-vagrant', 
    '15x-cloudinit',
    '15s-cloudinit')]
  [string]
  $VyOSVersion,

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
  $var_file = "$PSScriptRoot\vars-VyOS$VyOSVersion.pkrvars.hcl"
  $machine = "VyOS$VyOSVersion-g2"
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
  "seems package is not ready"
}

$endDTM = (Get-Date)
Write-Host "[INFO]  - Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds" -ForegroundColor Yellow
