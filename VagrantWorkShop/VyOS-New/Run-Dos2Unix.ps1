Get-ChildItem -Path $PSScriptRoot -Recurse -Filter "*.sh" `
  | Select-Object -ExpandProperty VersionInfo `
  | Select-Object -ExpandProperty filename `
  | ForEach-Object {
    dos2unix $_
    $PSScriptRoot
  }

  Get-ChildItem -Path $PSScriptRoot -Recurse -Filter "*.yaml" `
  | Select-Object -ExpandProperty VersionInfo `
  | Select-Object -ExpandProperty filename `
  | ForEach-Object {
    dos2unix $_
    $PSScriptRoot
  }