@(
    
) | ForEach-Object {
    $path = $_
    Write-Host "Removing state for resource at path: $path"
    terraform state rm $path
}