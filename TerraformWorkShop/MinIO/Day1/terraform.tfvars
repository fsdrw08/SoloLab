prov_minio = {
  minio_server   = "minio-api.day1.sololab"
  minio_user     = "minioadmin"
  minio_password = "minioadmin"
  minio_ssl      = true
}

prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

buckets = [
  {
    bucket        = "tfstate"
    force_destroy = true
  },
  {
    bucket        = "loki"
    force_destroy = true
  },
  {
    bucket        = "gitea"
    force_destroy = true
  },
  {
    bucket        = "nexus3"
    force_destroy = true
  },
]

users = [
  {
    name                 = "tfstate"
    policies             = ["tfstate-readwrite"]
    hardcoded_credential = true
    access_key           = "terraform"
    secret_key           = "terraform"
    secret_key_version   = "1"
  },
  {
    name               = "loki"
    policies           = ["loki-readwrite"]
    secret_key_version = "1"
  },
  {
    name               = "gitea"
    policies           = ["gitea-readwrite"]
    secret_key_version = "1"
  },
  {
    name               = "nexus3"
    policies           = ["nexus3-readwrite"]
    secret_key_version = "1"
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
  {
    name   = "loki-readwrite"
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
                    "arn:aws:s3:::loki/*"
                ]
            }
        ]
    }
    EOF
  },
  {
    name   = "gitea-readwrite"
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
                    "arn:aws:s3:::gitea/*"
                ]
            }
        ]
    }
    EOF
  },
  {
    name   = "nexus3-readwrite"
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
                    "arn:aws:s3:::nexus3/*"
                ]
            }
        ]
    }
    EOF
  },
]
