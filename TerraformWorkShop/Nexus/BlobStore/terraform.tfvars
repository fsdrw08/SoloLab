prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

prov_sonatyperepo = {
  url = "https://nexus.day4.sololab"
  credential = {
    user = {
      vault_kvv2 = {
        mount = "kvv2_others"
        name  = "app-nexus"
        key   = "admin_username"
      }
    }
    password = {
      vault_kvv2 = {
        mount = "kvv2_others"
        name  = "app-nexus"
        key   = "admin_password"
      }
    }
  }
}

blob_store_s3 = {
  name = "minio.day1"
  bucket = {
    name   = "nexus3"
    region = "us-east-1"
  }
  bucket_security = {
    access_key_id = {
      vault_kvv2 = {
        mount = "kvv2_minio"
        name  = "nexus3"
        key   = "access_key"
      }
    }
    secret_access_key = {
      vault_kvv2 = {
        mount = "kvv2_minio"
        name  = "nexus3"
        key   = "secret_key"
      }
    }
  }
  advanced_bucket_connection = {
    endpoint         = "https://minio-api.day1.sololab"
    force_path_style = true
  }

}
