resource "lynx_user" "user" {
  for_each = {
    for user in var.users : user.iac_id => user
  }
  name     = each.value.name
  email    = each.value.email
  role     = each.value.role
  password = each.value.password
}

locals {
  # users_member_of_teams = {
  #   for user in var.users :
  #   user.iac_id => user.member_of_teams
  # }
  # # convert "user -> team" mapping to "team -> user"
  # team_members = transpose(local.users_member_of_teams)
  users_iac_id = {
    for user in var.users :
    user.name => user.iac_id
  }
  # create a map of team name -> user iac_id
  team_members = {
    for team in var.teams :
    team.name => [
      for member in team.members :
      lookup(local.users_iac_id, member)
    ]
  }
}

resource "lynx_team" "team" {
  for_each = {
    for team in var.teams : team.iac_id => team
  }
  name        = each.value.name
  slug        = each.value.slug == null ? lower(each.value.name) : each.value.slug
  description = each.value.description

  members = [
    for member in lookup(local.team_members, each.value.name) : lynx_user.user[member].id
  ]
}

locals {
  # teams_member_of_projects = {
  #   for team in var.teams :
  #   team.iac_id => team.member_of_projects
  # }
  # # convert "team -> project" mapping to "project -> team"
  # projects_member = {
  #   for key, value in transpose(local.teams_member_of_projects) :
  #   # one project can only have one team
  #   key => value[0]
  # }
  projects_member = {
    for team in var.teams :
    team.name => team.iac_id
  }
}

resource "lynx_project" "project" {
  for_each = {
    for project in var.projects : project.iac_id => project
  }
  name        = each.value.name
  slug        = each.value.slug == null ? lower(each.value.name) : each.value.slug
  description = each.value.description

  team = {
    id = lynx_team.team[lookup(local.projects_member, each.value.team)].id
  }
}

locals {
  environments = flatten([
    for project in var.projects : [
      for environment in project.environments : {
        iac_id         = environment.iac_id
        name           = environment.name
        slug           = environment.slug
        username       = environment.username
        secret         = environment.secret
        project_iac_id = project.iac_id
      }
    ]
  ])
}

resource "lynx_environment" "environment" {
  for_each = {
    for environment in local.environments : environment.iac_id => environment
  }
  name     = each.value.name
  slug     = each.value.slug == null ? lower(each.value.name) : each.value.slug
  username = each.value.username
  secret   = each.value.secret

  project = {
    id = lynx_project.project[each.value.project_iac_id].id
  }
}
