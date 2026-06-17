variable "prov_vault" {
  type = object({
    address         = string
    skip_tls_verify = bool
    token           = optional(string, null)
  })
}

variable "jwt_auth" {
  type = object({
    path        = string
    description = optional(string, null)
    jwks_ca_pem = optional(object({
      plaintext = optional(string, null)
      vault_kvv2 = optional(object({
        mount = string
        name  = string
        key   = string
      }), null)
    }), null)
    jwks_url           = optional(string, null)
    jwt_supported_algs = optional(list(string), ["RS256"])
    default_role       = optional(string, null)
    roles = list(object({
      role_name               = string
      role_type               = optional(string, "jwt")
      bound_audiences         = list(string)
      user_claim              = optional(string, "/nomad_job_id")
      user_claim_json_pointer = optional(bool, true)
      claim_mappings          = optional(map(string), null)
      token_type              = optional(string, "service")
      token_policies          = optional(list(string), null)
      token_period            = optional(number, null)
      token_explicit_max_ttl  = optional(number, 0)
    }))
  })
}

# variable "nomad_jwks_url" {
#   description = "The URL used by Vault to access Nomad's JWKS information. It should be reachable by all Vault servers and resolve to multiple Nomad agents for high-availability, such as through a proxy or a DNS entry with multiple IP addresses."
#   type        = string
# }

# # Optional variables.

# variable "jwt_auth_path" {
#   description = "The path to mount the JWT auth backend used by Nomad."
#   type        = string
#   default     = "jwt-nomad"
# }

# variable "role_name" {
#   description = "The name of the ACL role created and used by default for Nomad workload tokens."
#   type        = string
#   default     = "nomad-workloads"
# }

# variable "default_policy_name" {
#   description = "The name of the default ACL policy created for Nomad workloads when `policy_names` is not defined."
#   type        = string
#   default     = "nomad-workloads"
# }

# variable "policy_names" {
#   description = "A list of ACL policy names to apply to tokens generated for Nomad workloads."
#   type        = list(string)
#   default     = []
# }

# variable "audience" {
#   description = "The `aud` value set on Nomad workload identities for Vault. Must match in Nomad, either in the agent configuration for `vault.default_identity.aud` or in the job task identity for Vault."
#   type        = string
#   default     = "vault.io"
# }

# variable "token_ttl" {
#   description = "The time-to-live value for tokens in seconds. Nomad attempts to automatically renew tokens before they expire."
#   type        = number
#   default     = 3600
# }
