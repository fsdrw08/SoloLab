variable "hyperv_host" {
  type    = string
  default = "127.0.0.1"
}

variable "hyperv_port" {
  type    = number
  default = 5985
}

variable "hyperv_user" {
  type = string
}

variable "hyperv_password" {
  type = string
}

variable "vhd_dir" {
  type    = string
  default = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
}

variable "vm_name" {
  type = string
}

variable "ignition_content" {
  type = string
}

variable "windows_create_file" {
  type        = string
  description = "command in windows powershell to create cloudinit text file"
  default     = <<-EOT
  mkdir -p $tempDir
  $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
  [System.IO.File]::WriteAllLines((Join-Path -Path $tempDir -ChildPath $filename), $content, $Utf8NoBomEncoding)
  EOT
  # $content | Out-File -FilePath (Join-Path -Path $tempDir -ChildPath $filename) -Encoding UTF8
}

variable "bash_create_file" {
  type        = string
  description = "command in bash to create cloudinit text file"
  default     = <<-EOT
  mkdir -p $tempDir
  echo $content > "$tempDir/$filename"
  EOT
}
