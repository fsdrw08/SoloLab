locals {
  role_key_list = flatten([
    for role in var.roles : [
      for permission in role.permissions : {
        role       = role.name
        key        = permission.key
        permission = permission.permission
      }
    ]
  ])
}

data "etcd_prefix_range_end" "range_end" {
  for_each = {
    for item in local.role_key_list : "${item.role}-${item.permission}" => item
  }
  key = each.value.key
}

resource "etcd_role" "role" {
  for_each = {
    for role in var.roles : role.name => role
  }
  name = each.value.name

  dynamic "permissions" {
    for_each = each.value.permissions
    content {
      permission = permissions.value.permission
      key        = permissions.value.key
      range_end  = data.etcd_prefix_range_end.range_end["${each.value.name}-${permissions.value.permission}"].range_end
    }
  }
}

resource "etcd_user" "user" {
  for_each = {
    for user in var.users : user.username => user
  }
  username = each.value.username
  password = each.value.password
  roles    = each.value.roles
}