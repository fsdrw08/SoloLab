variable "aliyun_profile" {
  description = "the profile name you run 'aliyun configure --profile <profile name>'"
  default     = "cn_hk"
}

variable "region" {
  description = "The region used to launch this module resources."
  type        = string
  default     = ""
}

variable "bucket_name" {
  description = "The name of the bucket"
  default     = "terraform-remote-backend-9c53"
}

variable "ots_instance_name" {
  description = "the name of OTS table which for storage to lock state during applies"
  default     = "tf-state-lock"
}

variable "ots_table_name" {
  description = "The name of OTS instance to which table belongs."
  default     = "terraform_remote_backend_lock_table"
}

#local_file
variable "state_path" {
  description = "The path directory of the state file will be stored. Examples: dev/frontend, prod/db, etc.."
  type        = string
  default     = ""
}

variable "state_name" {
  description = "Must have. The name of the state file. Examples: dev/tf.state, dev/frontend/tf.tfstate, etc.."
  type        = string
  default     = "root/terraform.tfstate"
}

variable "state_acl" {
  description = "Canned ACL applied to bucket."
  type        = string
  default     = "private"
}

variable "encrypt_state" {
  description = "Boolean. Whether to encrypt terraform state."
  type        = bool
  default     = false
}
