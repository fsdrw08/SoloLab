variable "boot_disk" {
  type = object({
    path        = string
    source_path = string
    size_bytes  = optional(number, null)
  })
}

variable "boot_disk_drive" {
  type = object({
    controller_location = number
    controller_number   = number
    path                = string
    controller_type     = optional(string, null)
  })
}

variable "additional_disk_drives" {
  type = list(
    object({
      controller_location = number
      controller_number   = number
      path                = string
      controller_type     = optional(string, null)
    })
  )
  default = []
}

variable "vm" {
  description = "hyperv vm instance config"
  type = object({
    name       = string
    cpu_count  = number
    generation = string
    memory = object({
      startup_bytes = number
      dynamic       = bool
      max_bytes     = optional(number)
      min_bytes     = optional(number)
    })
    boot_order = optional(
      list(object({
        type                = string
        controller_location = number
        controller_number   = number
        controller_type     = optional(string, null)
        name                = optional(string, null)
      })),
      null
    )
    dvd_drive = optional(
      list(object({
        controller_location = number
        controller_number   = number
        controller_type     = optional(string, null)
        iso_path            = optional(string, null)
      })),
      []
    )
    hard_disk_drive = optional(
      list(object({
        controller_location = number
        controller_number   = number
        controller_type     = optional(string, null)
        path                = string
      })),
      []
    )
    network_adapter = optional(
      list(object({
        name        = string
        switch_name = string
        mac_address = optional(string, null)
        vlan_id     = optional(number, null)
      })),
      []
    )
    notes                = optional(string, null)
    secure_boot          = optional(bool, null)
    secure_boot_template = optional(string, null)
    state = optional(
      object({
        # Off or Running. Omit to surface only the current state without managing transitions.
        desired = optional(string, null)
        # How Running -> Off transitions are performed. Optional. Omit to use Hyper-V's hard-power-off behavior (the same as terraform destroy semantics) without managing the attribute.
        # One of:
        #   turn_off: Stop-VM -TurnOff -Force -- hard power-off (equivalent to pulling the plug). Always safe; no integration-services dependency.
        #   graceful: Stop-VM -Force (no -TurnOff) -- sends an ACPI shutdown signal via Hyper-V integration services and waits for the guest to ack. Hangs indefinitely on guests without integration services running. Opt in only when the guest is known to ship and start integration services (modern Windows, most Linux distros with hyperv-daemons).
        shutdown_mode = optional(string, null)
      }),
      null
    )
  })
}
