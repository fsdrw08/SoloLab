$json = [Console]::In.ReadLine() | ConvertFrom-Json

$path = $jon.path
$fileName = $json.fileName
$fileContent = $json.fileContent

if (-not (Test-Path (Join-Path -Path $path -ChildPath $fileName))) {
     New-Item -Path $path -Name $fileName -ItemType File -Value $fileContent
     
     # $result = @{
     #      file = $fileName
     #      content = $fileContent
     # } | ConvertTo-Json
} else {
     $existFileContent = Get-Content -Path (Join-Path -Path $path -ChildPath $fileName)
     # $result = @{
     #      file = $fileName
     #      content = $existFileContent
     # } | ConvertTo-Json
}

$foobaz = @{foobaz = "$($json.foo) $($json.baz)"}
Write-Output $foobaz | ConvertTo-Json