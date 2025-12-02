prov_minio = {
  minio_server   = "minio-api.day0.sololab"
  minio_user     = "minioadmin"
  minio_password = "minioadmin"
  minio_ssl      = true
}

prov_vault = {
  address         = "https://vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

buckets = [
  {
    bucket = "loki"
  },
]

users = [
  {
    name     = "loki"
    policies = ["loki-readwrite"]
  },
]

policies = [
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
]
