terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = ">= 2.5.1"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate?sslmode=require&sslrootcert="
    schema_name = "Nomad-Job-WhoAmI"
  }
}

provider "nomad" {
  address     = var.prov_nomad.address
  skip_verify = var.prov_nomad.skip_verify
  # secret_id   = var.NOMAD_TOKEN
  # $env:NOMAD_TOKEN="xxxx"
}
