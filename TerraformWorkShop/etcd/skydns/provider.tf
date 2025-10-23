terraform {
  required_providers {
    etcd = {
      source  = "Ferlab-Ste-Justine/etcd"
      version = ">= 0.11.0"
    }
  }

  # backend "pg" {
  #   conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate?sslmode=require&sslrootcert="
  #   schema_name = "System-Day0-etcd-skydns"
  # }
  backend "s3" {
    bucket = "tfstate"     # Name of the S3 bucket
    key    = "etcd/skydns" # Name of the tfstate file

    endpoints = {
      s3 = "https://minio-api.vyos.sololab" # Minio endpoint
    }

    access_key = "terraform" # Access and secret keys
    secret_key = "terraform"

    region                      = "main" # Region validation will be skipped
    skip_credentials_validation = true   # Skip AWS related checks and validations
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
    skip_requesting_account_id  = true
    insecure                    = true
  }
}

provider "etcd" {
  endpoints = var.prov_etcd.endpoints
  ca_cert   = var.prov_etcd.ca_cert
  username  = var.prov_etcd.username
  password  = var.prov_etcd.password
  skip_tls  = var.prov_etcd.skip_tls
}
