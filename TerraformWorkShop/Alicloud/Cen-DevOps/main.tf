# cen
resource "alicloud_cen_instance" "cen" {
  provider    = alicloud.cn_gz
  name        = "DevOps"
  description = "This resource is managed by terraform"
}

resource "alicloud_cen_instance_attachment" "cen_attm_apsg" {
  provider                 = alicloud.ap_sg
  instance_id              = alicloud_cen_instance.cen.id
  child_instance_id        = alicloud_vpc.vpc_sg.id
  child_instance_type      = "VPC"
  child_instance_region_id = data.alicloud_regions.apsg.regions.0.id
}

resource "alicloud_cen_instance_attachment" "cen_attm_cngz" {
  provider                 = alicloud.cn_gz
  instance_id              = alicloud_cen_instance.cen.id
  child_instance_id        = alicloud_vpc.vpc_cngz.id
  child_instance_type      = "VPC"
  child_instance_region_id = data.alicloud_regions.cngz.regions.0.id
}

