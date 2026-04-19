prov_nexus = {
  insecure = true
  url      = "https://nexus.day3.sololab"
  username = "admin"
  password = "P@ssw0rd"
}

prov_vault = {
  address         = "https://vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

blob_store_s3 = {
  name = "minio.day0"
  bucket = {
    name       = "nexus3"
    region     = "us-east-1"
    expiration = -1
  }
  advanced_bucket_connection = {
    endpoint         = "https://minio-api.day0.sololab"
    force_path_style = true
  }
  bucket_security_value_refers = [
    {
      value_sets = [
        {
          name          = "access_key_id"
          value_ref_key = "access_key"
        },
        {
          name          = "secret_access_key"
          value_ref_key = "secret_key"
        }
      ]
      vault_kvv2 = {
        mount = "kvv2_minio"
        name  = "nexus3"
      }
    }
  ]

}
