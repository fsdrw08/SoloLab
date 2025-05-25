resource "lldap_user" "users" {
  for_each = {
    for user in var.users : user.user_id => user
  }
  username     = each.value.user_id
  email        = each.value.email
  password     = each.value.password
  display_name = each.value.display_name
}

resource "lldap_group" "groups" {
  for_each = {
    for group in var.groups : group.iac_id => group
  }
  display_name = each.value.display_name
}

# data "lldap_groups" "groups" {
#   depends_on = [lldap_group.groups]
# }

# locals {
#   # groups = {
#   #   for group in data.lldap_groups.groups.groups : group.display_name => group.id
#   # }

#   memberships = flatten([
#     for group in var.groups : [
#       for membership in setproduct([group.iac_id], group.members) : join(":", membership)
#     ]
#   ])
#   # memberships = flatten([
#   #   for group in var.groups : [
#   #     for membership in setproduct([group.display_name], group.members) : join(":", membership)
#   #   ]
#   # ])
# }

# output "user_guid" {
#   value = local.user_guid
# }
# output "memberships" {
#   value = local.memberships
# }

resource "lldap_group_memberships" "memberships" {
  for_each = {
    for group in var.groups : group.iac_id => group
  }
  group_id = lldap_group.groups[each.key].id
  user_ids = toset(flatten([
    for group in var.groups : group.members
    if group.iac_id == each.key
  ]))
}

# resource "lldap_member" "memberships" {
#   depends_on = [
#     lldap_user.users,
#     lldap_group.groups
#   ]
#   for_each = {
#     for key, membership in local.memberships : membership => key
#   }

#   # group_id = lookup(local.groups, element(split(":", each.key), 0))
#   group_id = lldap_group.groups[element(split(":", each.key), 0)].id
#   user_id  = element(split(":", each.key), 1)
# }

resource "lldap_member" "readonly" {
  depends_on = [lldap_user.users]
  group_id   = 3 # lldap_strict_readonly
  user_id    = "readonly"
}
