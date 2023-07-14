# data
data "alicloud_vpcs" "vpcs" {

}

# cen
resource "alicloud_cen_instance" "cen" {
  cen_instance_name = var.cen_name
  description       = "This resource is managed by terraform"
}

# # https://github.com/terraform-alicloud-modules/terraform-alicloud-vpc-peering-multi-region/blob/master/main.tf
# resource "alicloud_cen_bandwidth_package" "cenbwp" {
#   bandwidth                  = var.bandwidth
#   cen_bandwidth_package_name = var.cen_bandwidth_package_name
#   description                = "This resource is managed by terraform"
#   geographic_region_a_id     = var.geographic_region_a_id
#   geographic_region_b_id     = var.geographic_region_b_id
#   payment_type               = var.payment_type
#   period                     = var.period
# }

# resource "alicloud_cen_bandwidth_package_attachment" "bwp" {
#   instance_id          = alicloud_cen_instance.cen.id
#   bandwidth_package_id = alicloud_cen_bandwidth_package.cenbwp.id
# }

# resource "alicloud_cen_instance_attachment" "cen_attm" {
#   instance_id              = alicloud_cen_instance.cen.id
#   child_instance_id        = alicloud_vpc.vpc_sg.id
#   child_instance_type      = "VPC"
#   child_instance_region_id = data.alicloud_regions.apsg.regions.0.id
# }

# resource "alicloud_cen_bandwidth_limit" "cbl" {
#   instance_id = alicloud_cen_instance.cen.id
#   region_ids = [
#     var.child_instance_region_id_1,
#     var.child_instance_region_id_2
#   ]
#   bandwidth_limit = var.bandwidth_limit
# }
