# https://cloud.tencent.com/developer/article/1987762

$projectPath = git rev-parse --show-toplevel
$plugin_cache_dir = Join-Path -Path $ENV:USERPROFILE.Replace("\","/") -ChildPath ".terraform.d/terraform-plugin-cache"
# plugin_cache_dir   = "$projectPath/TerraformWorkShop/terraform.d/plugins"
# $provider_installation = @"
# provider_installation {
#   filesystem_mirror {
#     path    = "$projectPath/TerraformWorkShop/terraform.d/plugins"
#     include = ["registry.terraform.io/*/*"]
#   }
#   direct {
#     exclude = ["registry.terraform.io/*/*"]
#   }
# }
# "@
if ($projectPath) {
    $TF_CLI_CONFIG_FILE = 
    @"
plugin_cache_dir = $plugin_cache_dir
disable_checkpoint = true
"@
    # https://developer.hashicorp.com/terraform/cli/config/config-file#locations
    $TF_CLI_CONFIG_FILE | Out-File $(Join-Path -Path $env:APPDATA -ChildPath "terraform.rc") -Verbose
}

# $env:TF_CLI_CONFIG_FILE = "$PSScriptRoot\terraform.rc"
# $env:TF_PLUGIN_CACHE_DIR = "$PSScriptRoot\terraform.d\plugin-cache"