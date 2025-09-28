prov_sftpgo = {
  host     = "https://sftpgo.day0.sololab"
  username = "admin"
  password = "P@ssw0rd"
}

groups = [
  {
    name = "app-sftpgo-prim-ignition"
    user_settings = {
      filesystem = {
        provider = 0
      }
    }
    virtual_folders = [{
      name         = "ignition"
      virtual_path = "/ignition"
      quota_size   = 0
      quota_files  = 0
    }]
  }
]
