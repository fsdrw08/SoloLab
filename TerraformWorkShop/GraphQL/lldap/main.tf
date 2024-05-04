# resource "graphql_mutation" "user" {
#   read_query_variables = {
#     "id" = "user3"
#   }
#   delete_mutation_variables = {
#     "id" = "user321"
#   }

#   mutation_variables = {
#     user = jsonencode({
#       id          = "user3"
#       email       = "user3@mail.service.consul"
#       displayName = "user3"
#       firstName   = ""
#       lastName    = ""
#       }
#     )
#   }

#   compute_mutation_keys = {
#     "userId" = "user.id"
#   }

#   #   https://github.com/Zepmann/lldap-cli/blob/main/lldap-cli
#   create_mutation = "mutation createUser($user:CreateUserInput!){createUser(user:$user){id email displayName firstName lastName avatar}}"
#   update_mutation = "mutation updateUser($user:UpdateUserInput!){updateUser(user:$user){ok}}"
#   delete_mutation = "mutation deleteUser($userId:String!){deleteUser(userId:$userId){ok}}"
#   read_query      = "query getUserInfo($id:String!){user(userId:$id){id email displayName firstName lastName}}"
# }

# data "http" "groupId" {
#   url = var.lldap_endpoint
#   request_headers = {
#     Content-Type  = "application/json"
#     Authorization = var.lldap_authz_header
#   }
#   method = "POST"
#   request_body = jsonencode(
#     {
#       query    = "query getGroups{groups{id creationDate uuid displayName}}"
#       variable = {}
#     }
#   )
# }

# output "test" {
#   value = max(jsondecode(data.http.groupId.response_body).data.groups.*.id...)
#   #   value = one(
#   #     [
#   #       for group in jsondecode(data.http.groupId.response_body).data.groups : group.id if group.displayName == "group2"
#   #     ]
#   #   )
# }

resource "graphql_mutation" "group" {
  #   depends_on = [graphql_mutation.user]
  mutation_variables = {
    group = "group2"
  }
  compute_mutation_keys = {
    "id" = "createGroup.id"
  }
  # https://github.com/sullivtr/terraform-provider-graphql/issues/94
  compute_from_create = true
  #   delete_mutation_variables = {
  #     "id" = max(jsondecode(data.http.groupId.response_body).data.groups.*.id...)
  #   }
  #   read_query_variables = {
  #     "id" = max(jsondecode(data.http.groupId.response_body).data.groups.*.id...)
  #   }

  #   https://github.com/Zepmann/lldap-cli/blob/main/lldap-cli
  create_mutation = "mutation createGroup($group:String!){createGroup(name:$group){id}}"
  update_mutation = "mutation updateGroup($groupInfo:UpdateGroupInput!){updateGroup(group:$group){ok}}"
  delete_mutation = "mutation deleteGroup($id:Int!){deleteGroup(groupId:$id){ok}}"
  read_query      = "query getGroup($id:Int!){group(groupId:$id){id displayName}}"
}
