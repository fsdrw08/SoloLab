prov_nexus = {
  insecure = true
  url      = "https://nexus3.day3.sololab"
  username = "admin"
  password = "P@ssw0rd"
}

prov_vault = {
  address         = "https://vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

blob_store_s3 = {
  bucket = {
    name   = "nexus3"
    region = "us-east-1"
  }
}
