## to config alicloud oss provider

1. install aliyun cli
```powershell
winget install winget install Alibaba.AlibabaCloudCLI
```
then restart explorer, to let aliyun cli path take effect

2. config aliyun cli
```powershell
aliyun configure --profile default
Access Key Id []: ...
Access Key Secret []: ...
Default Region Id []: ap-southeast-1
```

for multi region config:
ref: [cen_proxy_sample/terraform.tf](https://github.com/mosuke5/terraform_examples_for_alibabacloud/blob/4f36f46dd3b5329a6e154f1c118308814641464e/cen_proxy_sample/terraform.tf)

```powershell
aliyun configure --profile ap_sg
Access Key Id []: ...
Access Key Secret []: ...
Default Region Id []: ap-southeast-1

aliyun configure --profile cn_hk
Access Key Id []: ...
Access Key Secret []: ...
Default Region Id []: cn-hongkong
```

3. put below key word in backend oss config
ref: https://developer.hashicorp.com/terraform/language/settings/backends/oss
```hcl
terraform {
  backend "oss" {
      profile             = "<the profile name (ap-sg in this case)>"
      ...
  }    
}
```

4. run teraform command
```powershell
terraform init -migrate-state
terraform init
```

## to rename terraform resource
0. run `terraform plan` to ensure tf resource is match and up to date, also markdown the target resource id which need to rename
1. rename it from tf file, save
2. import the exist resource to new name
```powershell
$resourceId = "eip-j6cbv9bwhvf9e0aewm1a1"
$resourceNewName = 'alicloud_eip_address.eip["DevOps-EIP_HK1"]'
$resourceId = "d-j6c51b8pqwfoicx2x4ek"
$resourceNewName = "alicloud_ecs_disk.d_data"
terraform import $resourceNewName $resourceId
```
3. remove the old resource name
```powershell
$resourceOldName = 'alicloud_eip_address.eip["DevOps-EIP_HK1"]'
terraform state rm $resourceOldName
```

## resource create procedure
1. Create OSS to store terraform state file, then move local tf state to OSS
2. Create VPC(with IPV4 Gateway), see [VPC-DevOps](./VPC-DevOps/)
3. Create Internet relate stuff, see [VPC-DevOps](./VPC-DevOps/):
  - VSwitch for NAT Gateway
  - NAT Gateway
  - EIP (bind to NAT Gateway)
  - Vswitch route table
    - route entry(route all next hop traffic to nat gateway)
4. Enable CDT(cloud data transfer 云数据传输CDT, no terraform resource currently 2023.11) to reduce the internet cost https://cdt.console.aliyun.com/, ref: [什么是云数据传输CDT](https://www.alibabacloud.com/help/zh/cdt/product-overview/what-is-cdt)
5. Enable cloud filewall control policy, 访问控制-互联网边界-入向 https://yundun.console.aliyun.com
4. Create Subnet related stuff, see [Subnet-DevOps](./Subnet-DevOps/)
5. Create SSL cert, then upload to slb cert manager, see [SSL-DevOps](./SSL-DevOps/)
6. Create Server Load Balancer related stuff
7. Create NAS related stuff
8. Create compute related resources

```yaml
EIP:
  count: 1
  configs:
    - ...
    - address_name: ...
    - payment_type: ...
    - internet_charge_type: ...
    - auto_pay: ...
    - isp: ...
    - bandwidth: ...
    - description: ...

Res_VPC:
  Res_IPv4-GW:
    Before:
      Res_VSW-For-NAT:
        Configs:
          - cidr: "172.16.0.0/28"
          - route_table:
              route_entry:
                nexthop: Ipv4Gateway
        Before:
          Res_NAT-GW:
            Configs: 
              - Link_to: EIP...
              - snat:
                - IP: EIP..
              
  Res_VSW-For-OThers(internal):
    Configs:
      - nexthop: NAT-GW
      # apply after SLB
      - forward_entry: 
          https:
            - external_ip:
            - external_port: 443
            - internl_ip: slb_ip
            - internal_port: 443
          http:
            - external_ip:
            - external_port: 80
            - internl_ip: slb_ip
            - internal_port: 80
    Before:
      Res_SLB:
        Configs:
          - Certs: ACME
          - Listener-HTTPS: 
              FE: 443
              BE: 8080
          - Listener-HTTP:
              FE: 80
              listener_forward: on
              forward_port: 443
      Res_ECI-Jenkins:
      Res_ECS-Dev:
```