locals {
  secrets_vault_kvv2 = flatten([
    flatten([
      for value_refer in var.blob_store_s3.bucket_security_value_refers == null ? [] : var.blob_store_s3.bucket_security_value_refers : {
        mount = value_refer.vault_kvv2.mount
        name  = value_refer.vault_kvv2.name
      }
      if value_refer.vault_kvv2 != null
    ])
  ])
}

data "vault_kv_secret_v2" "secret" {
  for_each = local.secrets_vault_kvv2 == null ? null : {
    for secret_vault_kvv2 in local.secrets_vault_kvv2 : secret_vault_kvv2.name => secret_vault_kvv2
  }
  mount = each.value.mount
  name  = each.value.name
}

locals {
  s3_credential_list = flatten([
    for value_refer in var.blob_store_s3.bucket_security_value_refers : [
      for value_set in value_refer.value_sets : {
        name  = value_set.name
        value = data.vault_kv_secret_v2.secret[value_refer.vault_kvv2.name].data[value_set.value_ref_key]
      }
    ]
  ])
  s3_credential = {
    for item in local.s3_credential_list : item.name => item.value
  }
}

resource "nexus_blobstore_s3" "s3" {
  name = var.blob_store_s3.name

  bucket_configuration {
    bucket {
      name       = var.blob_store_s3.bucket.name
      region     = var.blob_store_s3.bucket.region
      expiration = var.blob_store_s3.bucket.expiration
    }

    bucket_security {
      access_key_id     = lookup(local.s3_credential, "access_key_id", null)
      secret_access_key = lookup(local.s3_credential, "secret_access_key", null)
    }

    advanced_bucket_connection {
      endpoint                 = var.blob_store_s3.advanced_bucket_connection.endpoint
      max_connection_pool_size = var.blob_store_s3.advanced_bucket_connection.max_connection_pool_size
      signer_type              = var.blob_store_s3.advanced_bucket_connection.signer_type
      force_path_style         = var.blob_store_s3.advanced_bucket_connection.force_path_style
    }
  }

  dynamic "soft_quota" {
    for_each = var.blob_store_s3.soft_quota == null ? [] : [var.blob_store_s3.soft_quota]
    content {
      limit = soft_quota.limit
      type  = soft_quota.type
    }
  }
}
