// https://github.com/hashicorp/packer-plugin-hyperv/issues/65
packer {
  required_plugins {
    hyperv = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/hyperv"
    }
    vagrant = {
      version = ">= 1.1.5"
      source = "github.com/hashicorp/vagrant"
    }
  }
}
