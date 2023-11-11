data "alicloud_resource_manager_resource_groups" "rg" {
  name_regex = var.resource_group_name_regex
}

data "alicloud_vpcs" "vpc" {
  name_regex        = var.vpc_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
}

data "alicloud_vswitches" "vsw" {
  name_regex        = var.vswitch_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.key.private_key_pem
  email_address   = var.acme_reg_email
}

# https://registry.terraform.io/providers/vancluever/acme/latest/docs/resources/certificate
# https://github.com/iits-consulting/terraform-opentelekomcloud-project-factory/blob/bd4df54ef38def4ed7c6455fa1536e8d81a6f960/modules/acme/certificate.tf
resource "acme_certificate" "cert" {
  for_each                  = var.domains
  account_key_pem           = acme_registration.reg.account_key_pem
  key_type                  = 2048 # RSA key of 2048 bits
  pre_check_delay           = 10
  common_name               = each.key
  subject_alternative_names = toset(concat([each.key], each.value))
  min_days_remaining        = var.acme_min_days_remaining
  dns_challenge {
    provider = "alidns"
    config = {
      ALICLOUD_ACCESS_KEY          = var.ALICLOUD_ACCESS_KEY
      ALICLOUD_SECRET_KEY          = var.ALICLOUD_SECRET_KEY
      ALICLOUD_PROPAGATION_TIMEOUT = 600
      ALICLOUD_POLLING_INTERVAL    = 5
      ALICLOUD_TTL                 = 86400
      ALICLOUD_HTTP_TIMEOUT        = 10
    }
  }
}

resource "alicloud_ssl_certificates_service_certificate" "ssl" {
  for_each = acme_certificate.cert

  certificate_name = each.value.common_name
  # https://registry.terraform.io/providers/vancluever/acme/latest/docs/resources/certificate#certificate_pem
  cert = "${each.value.certificate_pem}${each.value.issuer_pem}"
  key  = each.value.private_key_pem
}
