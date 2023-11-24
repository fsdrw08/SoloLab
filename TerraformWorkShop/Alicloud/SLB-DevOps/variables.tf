variable "resource_group_name_regex" {
  type = string
}

variable "vpc_name_regex" {
  type = string
}

# variable "vswitch_name_regex" {
#   type = string
# }

# variable "nat_gateway_name_regex" {
#   type = string
# }

variable "slb_web_internal" {
  type = map(object({
    vswitch_name_regex     = string
    name                   = string
    instance_charge_type   = string
    load_balancer_spec     = optional(string)
    listener_backend_port  = number
    nat_gateway_name_regex = optional(string)
    eip_name_regex         = optional(string)
  }))
}

# variable "slb_name" {
#   description = "The name of a new load balancer."
#   type        = string
# }

# variable "slb_instance_charge_type" {
#   description = <<-EOT
#   Support PayBySpec and PayByCLCU, 
#   This parameter takes effect when the value of payment_type (instance payment mode) is PayAsYouGo (pay-as-you-go).
#   EOT
#   type        = string
#   default     = "PayByCLCU"
# }

# variable "slb_spec" {
#   description = "The specification of the SLB instance. Only take effect when instance_charge_type = PayBySpec"
#   type        = string
#   default     = "slb.s1.small"
# }

# variable "slb_listener_backend_port" {
#   description = "Port used by the Server Load Balancer instance backend. Valid value range: [1-65535]."
#   type        = number
# }

# variable "slb_listener_sticky_session" {
#   description = "Whether to enable session persistence, Valid values are `on` and `off`. Default to `off`. This parameter is required and takes effect only when ListenerSync is set to `off`."
#   type        = string
#   default     = "on"
# }

# variable "slb_listener_sticky_session_type" {
#   description = "Mode for handling the cookie. If sticky_session is `on`, it is mandatory. Otherwise, it will be ignored. Valid values are insert and server. insert means it is inserted from Server Load Balancer; server means the Server Load Balancer learns from the backend server."
#   type        = string
#   default     = "server"
# }

# variable "slb_listener_cookie" {
#   description = "The cookie configured on the server. It is mandatory when `sticky_session` is `on` and `sticky_session_type` is `server`. Otherwise, it will be ignored. Valid value: String in line with RFC 2965, with length being 1- 200. It only contains characters such as ASCII codes, English letters and digits instead of the comma, semicolon or spacing, and it cannot start with $."
#   type        = string
#   default     = "cookie_test"
# }

# variable "slb_listener_cookie_timeout" {
#   description = "Cookie timeout. It is mandatory when sticky_session is `on` and sticky_session_type is `insert`. Otherwise, it will be ignored. Valid value range: [1-86400] in seconds."
#   type        = number
#   default     = 86400
# }
