terraform {
  required_providers {
    lldap = {
      source  = "tasansga/lldap"
      version = ">= 0.3.0"
    }
  }
  # backend "pg" {
  #   conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate?sslmode=require&sslrootcert="
  #   schema_name = "LDAP-LLDAP-Day0"
  # }
  backend "s3" {
    bucket = "tfstate"         # Name of the S3 bucket
    key    = "LDAP/LLDAP-Day0" # Name of the tfstate file

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

provider "lldap" {
  http_url                 = var.prov_lldap.http_url
  ldap_url                 = var.prov_lldap.ldap_url
  insecure_skip_cert_check = var.prov_lldap.insecure_skip_cert_check
  username                 = var.prov_lldap.username
  password                 = var.prov_lldap.password
  base_dn                  = var.prov_lldap.base_dn
}
