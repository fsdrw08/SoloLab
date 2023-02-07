[CmdletBinding()]
param (
    [Parameter()]
    [ValidateSet('36','37')]
    [int16]
    $FedoraVersion
)

#Verify the pre-request
$Ready = $true
@"
packer
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
  $template_file="$PSScriptRoot\tmpl-hv_g2-fedora.pkr.hcl"
  $var_file="$PSScriptRoot\vars-fedora$FedoraVersion.pkrvars.hcl"
  $machine="Fedora $FedoraVersion"
  $packer_log=0
  
  if ((Test-Path -Path "$template_file") -and (Test-Path -Path "$var_file")) {
    Write-Output "Template and var file found"
    Write-Output "Building: $machine"
    $currentLocation = (Get-Location).Path
    Set-Location $PSScriptRoot
    try {
      $env:PACKER_LOG=$packer_log
      packer validate -var-file="$var_file" "$template_file"
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
      
      $env:PACKER_LOG=$packer_log
      packer version
      packer build --force -var-file="$var_file" "$template_file"
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

$endDTM = (Get-Date)
Write-Host "[INFO]  - Elapsed Time: $(($endDTM - $startDTM).TotalSeconds) seconds" -ForegroundColor Yellow
