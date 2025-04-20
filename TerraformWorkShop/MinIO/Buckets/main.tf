resource "minio_s3_bucket" "buckets" {
  for_each = {
    for bucket in var.buckets : bucket.name => bucket
  }
  bucket = each.value.name
  acl    = each.value.acl
}

# resource "minio_s3_bucket_policy" "bucket_policies" {
#   for_each = {
#     for bucket in var.buckets : bucket.policy == null ? null : bucket.name => bucket
#   }
#   bucket = each.value.name
#   policy = each.value.policy
# }
