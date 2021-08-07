@"
dos2unix
"@ -split "`r`n" | ForEach-Object {
  if (!(Get-Command $_)) {
    [bool]$Ready = $false
  }
  $Ready
}

# Build images
if ($Ready -ne $false) {
  # Convert dos format to unix format
  "dos2unix"
  Get-ChildItem -Path $PSScriptRoot -Recurse `
    | Where-Object {$_.Name -like "values*" } `
    | Select-Object -ExpandProperty VersionInfo `
    | Select-Object -ExpandProperty filename `
    | ForEach-Object {
      #[io.file]::WriteAllText($_, ((Get-Content -Raw  $_) -replace "`r`n","`n"))
      dos2unix $_
    }
}