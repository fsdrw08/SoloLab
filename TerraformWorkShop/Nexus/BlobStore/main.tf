data "vault_kv_secret_v2" "secret" {
  for_each = {
    for key in keys(var.blob_store_s3.bucket_security) : key => var.blob_store_s3.bucket_security[key]
    if var.blob_store_s3.bucket_security[key].vault_kvv2 != null
  }
  mount = each.value.vault_kvv2.mount
  name  = each.value.vault_kvv2.name
}

locals {
  bucket_security = {
    access_key_id     = contains(keys(var.blob_store_s3.bucket_security), "access_key_id") ? var.blob_store_s3.bucket_security["access_key_id"].plaintext != null ? var.blob_store_s3.bucket_security["access_key_id"].plaintext : var.blob_store_s3.bucket_security["access_key_id"].vault_kvv2 == null ? null : data.vault_kv_secret_v2.secret["access_key_id"].data[var.blob_store_s3.bucket_security["access_key_id"].vault_kvv2.key] : null
    secret_access_key = contains(keys(var.blob_store_s3.bucket_security), "secret_access_key") ? var.blob_store_s3.bucket_security["secret_access_key"].plaintext != null ? var.blob_store_s3.bucket_security["secret_access_key"].plaintext : var.blob_store_s3.bucket_security["secret_access_key"].vault_kvv2 == null ? null : data.vault_kv_secret_v2.secret["secret_access_key"].data[var.blob_store_s3.bucket_security["secret_access_key"].vault_kvv2.key] : null
  }
}

resource "sonatyperepo_blob_store_s3" "s3" {
  name = var.blob_store_s3.name

  bucket_configuration = {
    bucket = {
      name   = var.blob_store_s3.bucket.name
      prefix = var.blob_store_s3.bucket.prefix
      region = var.blob_store_s3.bucket.region
    }

    bucket_security = {
      access_key_id     = local.bucket_security.access_key_id
      secret_access_key = local.bucket_security.secret_access_key
    }

    advanced_bucket_connection = {
      endpoint                 = var.blob_store_s3.advanced_bucket_connection.endpoint
      max_connection_pool_size = var.blob_store_s3.advanced_bucket_connection.max_connection_pool_size
      signer_type              = var.blob_store_s3.advanced_bucket_connection.signer_type
      force_path_style         = var.blob_store_s3.advanced_bucket_connection.force_path_style
    }
  }

  soft_quota = var.blob_store_s3.soft_quota
}
