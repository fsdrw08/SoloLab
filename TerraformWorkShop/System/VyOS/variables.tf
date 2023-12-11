variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "windows_download_consul" {
  type    = string
  default = <<-EOT
  if (-not (Test-Path $consulBin)) {
    curl.exe -s -o "$env:userprofile\AppData\Local\Temp\consul.zip" https://releases.hashicorp.com/consul/1.17.0/consul_1.17.0_linux_amd64.zip
    tar.exe -x -f "$env:userprofile\AppData\Local\Temp\consul.zip"
    mv "$env:userprofile\AppData\Local\Temp\consul" $consulBin
  }
  EOT
}
