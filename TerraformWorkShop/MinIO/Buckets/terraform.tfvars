prov_minio = {
  minio_server   = "minio-api.day1.sololab"
  minio_user     = "minioadmin"
  minio_password = "minioadmin"
  minio_ssl      = true
}

buckets = [
  {
    name = "bin"
    acl  = "public-read"
  },
]
