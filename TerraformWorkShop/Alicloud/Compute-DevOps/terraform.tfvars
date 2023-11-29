resource_group_name_regex = "^DevOps-Root"
vpc_name_regex            = "^DevOps-VPC"
nat_gateway_name_regex    = "^DevOps-NGw_HKB1$"
eip_address_name_regex    = "^DevOps-EIP_HK1"
eip_index                 = 0
vswitch_name_regex        = "^DevOps-Sub_1_VSw"
security_group_name_regex = "^DevOps-Sub_1_SG"
data_disk_name_regex      = "^DevOps-D_gitlab_data"
ecs_image_name_regex      = "^centos_stream_9_uefi_x64"

ecs_instance_type        = "ecs.t6-c1m4.large" # ecs.t6-c1m2.large
ecs_instance_name        = "DevOps-ECS_gitlab"
ecs_system_disk_name     = "DevOps-D_git_boot"
ecs_server_name          = "git"
ecs_status               = "Running"
ssh_forward_entry_name   = "DevOps-fwd_git_ssh"
http_forward_entry_name  = "DevOps-fwd_git_http"
https_forward_entry_name = "DevOps-fwd_git_https"
