variable "resource_group_name_regex" {
  type    = string
  default = "^DevOps-Root"
}

variable "vpc_name_regex" {
  type    = string
  default = "^DevOps-VPC"
}

variable "vswitch_name_regex" {
  type    = string
  default = "^DevOps-Sub_1_VSw"
}

variable "security_group_name_regex" {
  type    = string
  default = "^DevOps-Sub_1_SG"
}

variable "rds_pgsql_version" {
  description = "postgresql database version for gitlab"
  type        = string
  default     = "15.0"
}

variable "rds_pgsql_category" {
  description = <<-EOT
  The RDS edition of the instance. If you want to create a serverless instance, you must use this value. Valid values:
    Basic: Basic Edition.
    HighAvailability: High-availability Edition.
    AlwaysOn: Cluster Edition.
    Finance: Enterprise Edition.
    cluster: MySQL Cluster Edition. (Available in 1.202.0+)
    serverless_basic: RDS Serverless Basic Edition. This edition is available only for instances that run MySQL and PostgreSQL. (Available in 1.200.0+)
    serverless_standard: RDS Serverless Basic Edition. This edition is available only for instances that run MySQL and PostgreSQL. (Available in 1.204.0+)
    serverless_ha: RDS Serverless High-availability Edition for SQL Server. (Available in 1.204.0+)
  EOT
  type        = string
  default     = "serverless_basic"
}

# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/db_instance#instance_charge_type
variable "rds_pgsql_charge_type" {
  description = "Valid values are Prepaid, Postpaid, Serverless, Default to Postpaid. Currently, the resource only supports PostPaid to PrePaid."
  type        = string
  default     = "Serverless"
}

# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/db_instance#db_instance_storage_type
variable "rds_pgsql_storage" {
  description = <<-EOT
  The storage type of the instance. Serverless instance, only cloud_essd can be selected. Valid values:
    cloud_ssd: specifies to use standard SSDs.
    cloud_essd: specifies to use enhanced SSDs (ESSDs).
    cloud_essd2: specifies to use enhanced SSDs (ESSDs).
    cloud_essd3: specifies to use enhanced SSDs (ESSDs).
  EOT
  type        = string
  default     = "cloud_ssd"
}

variable "eci_group_name" {
  description = "The name of the container group."
  type        = string
}

variable "ecs_instance_type" {
  description = "The type of the ECS instance to run the ECI."
  type        = string
  default     = "ecs.t6-c1m4.large "
}

variable "eci_restart_policy" {
  description = "The restart policy of the container group. Valid values: Always, Never, OnFailure."
  type        = string
  default     = "OnFailure"
}

variable "eci_image_uri" {
  description = "The image of the container, see https://hub.docker.com/r/gitlab/gitlab-ee"
  type        = string
  default     = "docker.io/gitlab/gitlab-ee:latest"
}

variable "GITLAB_OMNIBUS_CONFIG" {
  type = string
}
