variable "acr_namespaces" {
  type = list(object({
    name               = string # The name of the namespace
    auto_create        = bool   # When it is set to true, the repository is automatically created when new images are pushed. If it is set to false, create a repository for the image before pushing
    default_visibility = string # Default repository visibility in this namespace, PUBLIC or PRIVATE
    repos = list(object({
      name      = string # Name of container registry repository.
      summary   = string # (Required) The repository general information. It can contain 1 to 80 characters.
      repo_type = string # (Required) PUBLIC or PRIVATE, repo's visibility.
      detail    = string # The repository specific information. MarkDown format is supported, and the length limit is 2000.
    }))
    }
  ))
}
