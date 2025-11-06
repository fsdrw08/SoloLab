prov_minio = {
  minio_server   = "minio-api.day0.sololab"
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
    name   = "app-minio-admin"
    policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "admin:*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "kms:*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "s3:*"
                ],
                "Resource": [
                    "arn:aws:s3:::*"
                ]
            }
        ]
    }
    EOF
  },
  {
    name   = "app-minio-readwrite"
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
                    "arn:aws:s3:::*"
                ]
            }
        ]
    }
    EOF
  },
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
