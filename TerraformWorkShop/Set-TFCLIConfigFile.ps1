# https://cloud.tencent.com/developer/article/1987762

$projectPath = git rev-parse --show-toplevel
# $mirrorPath = "$projectPath/TerraformWorkShop/terraform.d/mirror" 
# "C:/Users/Public/Downloads/terraform.d/mirror" 
$mirrorPath = $(Join-Path -Path $env:PUBLIC -ChildPath "Downloads/terraform.d/mirror").Replace("\","/")

$provider_installation_block = @"
provider_installation {
  filesystem_mirror {
    path    = "$mirrorPath"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
"@

$plugin_cache_dir = $(Join-Path -Path $env:PUBLIC -ChildPath "Downloads/terraform.d/terraform-plugin-cache").Replace("\", "/")

$TF_CLI_CONFIG_FILE = 
@"
$provider_installation_block
plugin_cache_dir = "$plugin_cache_dir"
disable_checkpoint = true
"@

# https://developer.hashicorp.com/terraform/cli/config/config-file#locations
$TF_CLI_CONFIG_FILE | Out-File $(Join-Path -Path $env:APPDATA -ChildPath "terraform.rc") -Verbose

# $env:TF_CLI_CONFIG_FILE = "$PSScriptRoot\terraform.rc"
# $env:TF_PLUGIN_CACHE_DIR = "$PSScriptRoot\terraform.d\plugin-cache"