resource "minio_iam_policy" "policy" {
  for_each = {
    for policy in var.policies : policy.name => policy
  }
  name   = each.value.name
  policy = each.value.policy
  # name = "app-minio-admin"
  # policy = jsonencode({
  #   Version = "2012-10-17"
  #   Statement = [
  #     {
  #       Effect = "Allow"
  #       Action = [
  #         "admin:*"
  #       ]
  #     },
  #     {
  #       Effect = "Allow"
  #       Action = [
  #         "kms:*"
  #       ]
  #     },
  #     {
  #       Effect = "Allow"
  #       Action = [
  #         "s3:*"
  #       ],
  #       Resource = [
  #         "arn:aws:s3:::*"
  #       ]
  #     }
  #   ]
  # })
}
