---
marp: true
theme: default
title: Infrastructure Automation Tools
size: 16:9
paginate: true
---

## IT运维自动化及其工具介绍

### Intrduce of IT Operations Automation and Related Tools
<br>
<br>

##### 主讲人 
Windom

---

## IT运维的对象 The componenet of IT Opterations

![](Layers.png)

---
## 从资源使用的角度看云架构的演进
The cloud architectural evolution from a resource utilization point of view
![fit](The-cloud-architectural-evolution-from-a-resource-utilization-point-of-view.png)

---
## 机房动力环境监控 Data Center components monitoring

动力：市电、电源、蓄电池、UPS、发电机等
环境：温湿度、烟雾、漏水、门禁、视频等
监控：遥测、遥信、遥控、遥调
![auto](DC-Design.webp)


---

## 网络 Network

零配置部署 
Zero Touch Provisioning(ZTP)

![w](ZTP.png)
![bg vertical right fit](cisco-ztp.webp)

aka：配置路由器

---
## 裸金属 Bare Metal → 主机系统/虚拟化层 Host OS/Hyperversion

![](MAAS-diagram-grey.svg)

aka：装电脑，把系统镜像写入硬盘

---

Ventoy

![w:330](ventoy.png)
![w:800](ventoy_config.png)

---

Canonical MAAS

![w:800](maas.webp)
![w:500](maas_config.png)

--- 
### 虚拟化层 Hyperversion → 虚拟机镜像 VM Image
Hashicorp Packer
workflow
![](packer-workflow-2.png)

---
Hashicorp Packer
build process
![auto](packer-workflow-min.png.webp)

---
### 虚拟机镜像 VM Image → 虚拟机实例 VM Instance
Hashicorp Terraform
![w:700](terraform-packer.png)

---
Terraform workflow
![](terraform-workflow.webp)