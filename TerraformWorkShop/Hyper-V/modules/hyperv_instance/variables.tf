variable "name" {
  type        = string
  description = "Specifies the name of the new virtual machine."
}

variable "generation" {
  type        = optional(number, null)
  description = "Specifies the generation, as an integer, for the virtual machine. Valid values to use are 1, 2."
}

variable "automatic_critical_error_action" {
  type        = optional(string)
  default     = "Pause"
  description = "Specifies the action to take when the VM encounters a critical error, and exceeds the timeout duration specified by the AutomaticCriticalErrorActionTimeout cmdlet. Valid values to use are Pause, None."
}
