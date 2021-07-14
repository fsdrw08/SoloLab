#Verify the pre-request
@"
packer
dos2unix
mkisofs
"@ -split "`r`n" | ForEach-Object {
  if (!(Get-Command $_)) {
    [bool]$Ready = $false
  }
}

# Build images
if ($Ready -ne $false) {
  # Convert dos format to unix format
  "dos2unix"
  Get-ChildItem -Path $PSScriptRoot -Recurse -Filter "*.sh" `
    | Select-Object -ExpandProperty VersionInfo `
    | Select-Object -ExpandProperty filename `
    | ForEach-Object {
      #[io.file]::WriteAllText($_, ((Get-Content -Raw  $_) -replace "`r`n","`n"))
      dos2unix $_
    }

  # Get Start Time
  $startDTM = (Get-Date)

  # Variables 
  $template_file=".\Templates\hv_vyos130_g2_vagrant.pkr.hcl"
  $var_file=".\Variables\variables_vyos130.pkrvars.hcl"
  $machine="vyos"
  $packer_log=0
  #$InternalSwitch = "Internal Switch"

  if ((Test-Path -Path "$template_file") -and (Test-Path -Path "$var_file")) {
    Write-Output "Template and var file found"
    Write-Output "Building: $machine"
    try {
      $env:PACKER_LOG=$packer_log
      packer validate -var-file="$var_file" "$template_file"
    }
    catch {
      Write-Output "Packer validation failed, exiting."
      exit (-1)
    }
    try {
      Get-Job | Remove-Job -Force
      $env:PACKER_LOG=$packer_log
      packer version
      <#
      Start-Job -ScriptBlock { Start-Sleep 40; Add-VMNetworkAdapter -VMName $using:VMName -SwitchName $using:InternalSwitch;
        Set-VMFirmware -VMName $using:VMName -BootOrder (Get-VMHardDiskDrive -VMName $using:VMName),(Get-VMDvdDrive -VMName $using:VMName),(Get-VMNetworkAdapter -VMName $using:VMName)[0],(Get-VMNetworkAdapter -VMName $using:VMName)[1]}
      #>
        packer build --force -var-file="$var_file" "$template_file"
      #Get-Job | Remove-Job -Force
    }
    catch {
      Write-Output "Packer build failed, exiting."
      exit (-1)
    }
  }
  else {
    Write-Output "Template or var file not found - exiting"
    exit (-1)
  }

  $endDTM = (Get-Date)
  Write-Host "[INFO]  - Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds" -ForegroundColor Yellow
}