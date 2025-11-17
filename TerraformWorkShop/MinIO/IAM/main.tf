resource "minio_s3_bucket" "buckets" {
  for_each = {
    for bucket in var.buckets : bucket.bucket => bucket
  }
  bucket         = each.value.bucket
  acl            = each.value.acl
  bucket_prefix  = each.value.bucket_prefix
  force_destroy  = each.value.force_destroy
  object_locking = each.value.object_locking
  quota          = each.value.quota
}

resource "minio_iam_user" "users" {
  for_each = {
    for user in var.users : user.name => user
  }
  name = each.value.name
}

resource "random_password" "secret_key" {
  for_each = {
    for user in var.users : user.name => user
  }
  length = 10
}


resource "minio_accesskey" "users" {
  for_each = {
    for user in var.users : user.name => user
  }
  user               = minio_iam_user.users[each.value.name].name
  access_key         = each.value.access_key
  secret_key         = random_password.secret_key[each.value.name].result
  secret_key_version = sha256(random_password.secret_key[each.value.name].result)
}

resource "minio_iam_policy" "policies" {
  for_each = {
    for policy in var.policies : policy.name => policy
  }
  name   = each.value.name
  policy = each.value.policy
}

locals {
  assignments = flatten([
    for user in var.users : [
      for assignment in setproduct([user.name], user.policies) : format("${assignment[0]}:${assignment[1]}") #join(":", assignment)
    ]
  ])
}

resource "minio_iam_user_policy_attachment" "attachments" {
  for_each = {
    for key, assignment in local.assignments : assignment => key
  }
  user_name   = minio_iam_user.users[element(split(":", each.key), 0)].name
  policy_name = minio_iam_policy.policies[element(split(":", each.key), 1)].id
}

resource "vault_kv_secret_v2" "secret" {
  for_each = {
    for user in var.users : user.name => user
  }
  mount               = "kvv2-minio"
  name                = each.value.name
  delete_all_versions = true
  data_json = jsonencode(
    {
      access_key = minio_accesskey.users[each.value.name].access_key,
      # secret_key = minio_accesskey.users[each.value.name].secret_key
      secret_key = random_password.secret_key[each.value.name].result
    }
  )
}
