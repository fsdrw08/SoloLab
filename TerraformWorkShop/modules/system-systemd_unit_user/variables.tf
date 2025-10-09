variable "vm_conn" {
  type = object({
    host        = string
    port        = number
    user        = string
    password    = optional(string, null)
    private_key = optional(string, null)
  })
}

variable "units" {
  type = list(
    object({
      auto_start = object({
        enabled   = bool
        link_path = optional(string, null)
      })
      file = object({
        path    = string
        content = string
      })
      status = optional(string, "")
    })
  )
}
