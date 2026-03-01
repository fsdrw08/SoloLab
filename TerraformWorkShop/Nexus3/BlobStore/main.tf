resource "nexus_blobstore_s3" "s3" {
  name = var.blob_store_s3.name

  bucket_configuration {
    bucket {
      name   = var.blob_store_s3.bucket.name
      region = var.blob_store_s3.bucket.region
    }

    bucket_security {
      access_key_id     = var.blob_store_s3.bucket.access_key_id
      secret_access_key = var.blob_store_s3.bucket.secret_access_key
    }
  }

  soft_quota {
    limit = var.blob_store_s3.soft_quota.limit
    type  = var.blob_store_s3.soft_quota.type
  }
}
