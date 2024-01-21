data "alicloud_resource_manager_resource_groups" "rg" {
  name_regex = var.resource_group_name_regex
}

data "alicloud_alidns_domains" "domain" {
  domain_name_regex = var.domain_name_regex
}

# private key
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# acme cert
resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.key.private_key_pem
  email_address   = var.acme_reg_email
}

# https://registry.terraform.io/providers/vancluever/acme/latest/docs/resources/certificate
# https://github.com/iits-consulting/terraform-opentelekomcloud-project-factory/blob/bd4df54ef38def4ed7c6455fa1536e8d81a6f960/modules/acme/certificate.tf
resource "acme_certificate" "alidns" {
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

# resource "acme_certificate" "alidns" {
#   for_each = {
#     for k, v in data.alicloud_alidns_domains.domain.names :
#     v => k
#   }
#   account_key_pem = acme_registration.reg.account_key_pem
#   key_type        = 2048 # RSA key of 2048 bits
#   pre_check_delay = 10
#   common_name     = each.key
#   # subject_alternative_names = toset(concat([each.key], each.value))
#   subject_alternative_names = ["*.${each.key}"]
#   min_days_remaining        = var.acme_min_days_remaining
#   dns_challenge {
#     provider = "alidns"
#     config = {
#       ALICLOUD_ACCESS_KEY          = var.ALICLOUD_ACCESS_KEY
#       ALICLOUD_SECRET_KEY          = var.ALICLOUD_SECRET_KEY
#       ALICLOUD_PROPAGATION_TIMEOUT = 600
#       ALICLOUD_POLLING_INTERVAL    = 5
#       ALICLOUD_TTL                 = 86400
#       ALICLOUD_HTTP_TIMEOUT        = 10
#     }
#   }
# }

resource "alicloud_ssl_certificates_service_certificate" "acme_blue" {
  for_each = acme_certificate.alidns

  certificate_name = each.value.common_name
  # https://registry.terraform.io/providers/vancluever/acme/latest/docs/resources/certificate#certificate_pem
  cert = "${each.value.certificate_pem}${each.value.issuer_pem}"
  key  = each.value.private_key_pem
}

resource "alicloud_slb_server_certificate" "acme_blue" {
  for_each           = acme_certificate.alidns
  resource_group_id  = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  name               = each.value.common_name
  server_certificate = "${each.value.certificate_pem}${each.value.issuer_pem}"
  private_key        = each.value.private_key_pem
}
