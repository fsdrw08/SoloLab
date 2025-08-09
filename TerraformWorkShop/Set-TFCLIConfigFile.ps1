# https://cloud.tencent.com/developer/article/1987762

# $projectPath = git rev-parse --show-toplevel
# $mirrorPath = "$projectPath/TerraformWorkShop/terraform.d/mirror" 
# run command: (should run by powershell 7+):
# terraform providers mirror "C:/Users/Public/Downloads/terraform.d/mirror" 
$mirrorPathWin = Join-Path -Path $env:PUBLIC -ChildPath "Downloads/terraform.d/mirror"
if (-not (Test-Path -Path $mirrorPathWin)) {
  New-Item -ItemType Directory -Path $mirrorPathWin
}

# put the mirror dir var into the tf config block
$mirrorPath = $mirrorPathWin.Replace("\","/")
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

$plugin_cache_dirWin = $(Join-Path -Path $env:PUBLIC -ChildPath "Downloads/terraform.d/terraform-plugin-cache").Replace("\", "/")
if (-not (Test-Path -Path $plugin_cache_dirWin)) {
  New-Item -ItemType Directory -Path (Join-Path -Path $env:PUBLIC -ChildPath "Downloads/terraform.d/terraform-plugin-cache")
}

# prepare the tf cli config file
$plugin_cache_dir = $plugin_cache_dirWin.Replace("\", "/")
$TF_CLI_CONFIG_FILE = 
@"
$provider_installation_block
plugin_cache_dir = "$plugin_cache_dir"
disable_checkpoint = true
"@

# put the tf cli config file into $env:APPDATA\terraform.rc
# https://developer.hashicorp.com/terraform/cli/config/config-file#locations
$TF_CLI_CONFIG_FILE | Out-File $(Join-Path -Path $env:APPDATA -ChildPath "terraform.rc") -Verbose

# $env:TF_CLI_CONFIG_FILE = "$PSScriptRoot\terraform.rc"
# $env:TF_PLUGIN_CACHE_DIR = "$PSScriptRoot\terraform.d\plugin-cache"