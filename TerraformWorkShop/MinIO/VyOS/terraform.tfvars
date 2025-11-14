prov_minio = {
  minio_server   = "minio-api.vyos.sololab"
  minio_user     = "minioadmin"
  minio_password = "minioadmin"
  minio_ssl      = true
}

buckets = [
  {
    bucket = "tfstate"
  },
]

users = [
  {
    name               = "tfstate"
    policies           = ["tfstate-readwrite"]
    access_key         = "terraform"
    secret_key         = "terraform"
    secret_key_version = "v1"
  },
]

policies = [
  {
    name   = "tfstate-readwrite"
    policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:*"
                ],
                "Resource": [
                    "arn:aws:s3:::tfstate/*"
                ]
            }
        ]
    }
    EOF
  },
]
