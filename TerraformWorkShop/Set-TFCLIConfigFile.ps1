Set-Location $PSScriptRoot

$projectPath=git rev-parse --show-toplevel

if ($projectPath) {
    $TF_CLI_CONFIG_FILE = 
@"
plugin_cache_dir   = "$projectPath/TerraformWorkShop/terraform.d/plugins"

disable_checkpoint = true
"@
    # https://developer.hashicorp.com/terraform/cli/config/config-file#locations
    $TF_CLI_CONFIG_FILE | Out-File $(Join-Path -Path $env:APPDATA -ChildPath "terraform.rc") -Verbose
}

# $env:TF_CLI_CONFIG_FILE = "$PSScriptRoot\terraform.rc"
# $env:TF_PLUGIN_CACHE_DIR = "$PSScriptRoot\terraform.d\plugin-cache"