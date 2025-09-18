# resource "lynx_user" "user" {
#   for_each = {
#     for user in var.users : user.iac_id => user
#   }
#   name     = each.value.name
#   email    = each.value.email
#   role     = each.value.role
#   password = each.value.password
# }

locals {
  member_of = {
    for user in var.users :
    user.name => user.member_of
  }
  transpose = transpose(local.member_of)
}

output "debug" {
  value = local.transpose
}

# resource "lynx_team" "monitoring" {
#   for_each = {
#     for team in var.teams : team.iac_id => team
#   }
#   name        = each.value.name
#   slug        = each.value.slug
#   description = each.value.description

#   members = [
#     for user in lynx_user
#     # lynx_user.stella.id,
#     # lynx_user.skylar.id,
#     # lynx_user.erika.id,
#     # lynx_user.adriana.id
#   ]
# }

# resource "lynx_project" "grafana" {
#   name        = "Grafana"
#   slug        = "grafana"
#   description = "Grafana Project"

#   team = {
#     id = lynx_team.monitoring.id
#   }
# }

# resource "lynx_environment" "prod" {
#   name     = "Development"
#   slug     = "dev"
#   username = "~username-here~"
#   secret   = "~secret-here~"

#   project = {
#     id = lynx_project.grafana.id
#   }
# }
