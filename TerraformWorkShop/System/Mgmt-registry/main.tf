resource "null_resource" "registry_init" {
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  triggers = {
    dirs        = "/mnt/data/registry"
    chown_user  = "vyos"
    chown_group = "users"
    chown_dir   = "/mnt/data/registry"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/registry/init.sh", {
        dirs        = self.triggers.dirs
        chown_user  = self.triggers.chown_user
        chown_group = self.triggers.chown_group
        chown_dir   = self.triggers.chown_dir
      })
    ]
  }
}

data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

module "registry" {
  source = "../modules/registry"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  install = {
    # https://github.com/distribution/distribution/releases
    tar_file_source = "http://files.day0.sololab/releases/registry_2.8.3_linux_amd64.tar.gz"
    tar_file_path   = "/home/vyos/registry_2.8.3_linux_amd64.tar.gz"
    bin_file_dir    = "/usr/bin"
  }
  runas = {
    take_charge = false
    user        = "vyos"
    group       = "users"
  }
  config = {
    main = {
      basename = "config.yml"
      content = templatefile("${path.root}/registry/config.yml", {
        REGISTRY_STORAGE_DELETE_ENABLED           = "true"
        REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY = "/var/lib/registry"
        # https://stackoverflow.com/questions/66440572/private-registry-not-working-properly-after-deleting-an-image
        REGISTRY_STORAGE_CACHE_BLOBDESCRIPTOR = "\"\""
        # https://github.com/distribution/distribution/issues/1230#issuecomment-298428247
        REGISTRY_AUTH_HTPASSWD_PATH   = "/etc/registry/htpasswd"
        REGISTRY_AUTH_HTPASSWD_REALM  = "basic-realm"
        REGISTRY_HTTP_ADDR            = "192.168.255.1:5000"
        REGISTRY_HTTP_NET             = "tcp"
        REGISTRY_HTTP_HOST            = "https://registry.day0.sololab"
        REGISTRY_HTTP_DEBUG_ADDR      = "192.168.255.1:5001"
        REGISTRY_HTTP_TLS_CERTIFICATE = "/etc/registry/certs/registry.crt"
        REGISTRY_HTTP_TLS_KEY         = "/etc/registry/certs/registry.key"
        # https://github.com/atareao/self-hosted/blob/67271037979fadd16aaf69f3dfad1411f60b3931/registry/config.yml#L33
        REGISTRY_HTTP_HEADERS_Access-Control-Allow-Origin      = "[https://registry-ui.day0.sololab]"
        REGISTRY_HTTP_HEADERS_Access-Control-Allow-Credentials = "[true]"
        REGISTRY_HTTP_HEADERS_Access-Control-Allow-Headers     = "[Authorization,Accept,Cache-Control]"
        REGISTRY_HTTP_HEADERS_Access-Control-Allow-Methods     = "[HEAD,GET,OPTIONS,DELETE]"
        REGISTRY_HTTP_HEADERS_Access-Control-Expose-Headers    = "[Docker-Content-Digest]"
      })
    }
    certs = {
      ca_basename   = "ca.crt"
      ca_content    = data.terraform_remote_state.root_ca.outputs.int_ca_pem
      cert_basename = "registry.crt"
      cert_content = join("", [
        lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "registry", null),
        data.terraform_remote_state.root_ca.outputs.int_ca_pem,
      ])
      key_basename = "registry.key"
      key_content  = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "registry", null)
      sub_dir      = "certs"
    }
    dir = "/etc/registry"
  }
  storage = {
    dir_link   = "/var/lib/registry"
    dir_target = "/mnt/data/registry"
  }
  service = {
    status  = "started"
    enabled = true
    systemd_service_unit = {
      content = templatefile("${path.root}/registry/registry.service", {
        user        = "vyos"
        group       = "users"
        config_path = "/etc/registry/config.yml"
      })
      path = "/etc/systemd/system/registry.service"
    }
  }
}

module "registry_restart" {
  depends_on = [module.registry]
  source     = "../modules/systemd_path"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  systemd_path_unit = {
    path = "/etc/systemd/system/registry_restart.path"
    content = templatefile("${path.root}/registry/restart.path", {
      PathModified = [
        "/etc/registry/config.yml",
      ]
      PathExistsGlob = []
    })
  }
  systemd_service_unit = {
    path = "/etc/systemd/system/registry_restart.service"
    content = templatefile("${path.root}/registry/restart.service", {
      AssertPathExists = "/etc/systemd/system/registry.service"
      target_service   = "registry.service"
    })
  }
}
