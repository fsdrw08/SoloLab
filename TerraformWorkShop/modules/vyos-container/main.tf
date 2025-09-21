resource "null_resource" "load_image" {
  for_each = {
    for workload in var.workloads : workload.name => workload
  }
  triggers = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
    image    = each.value.image
  }
  connection {
    type     = "ssh"
    host     = self.triggers.host
    port     = self.triggers.port
    user     = self.triggers.user
    password = self.triggers.password
  }
  provisioner "remote-exec" {
    inline = [
      <<-EOT
        #!/bin/bash
        CONTAINER_IMAGE=${each.value.image}
        ARCHIVE_IMAGE=${each.value.local_image}
        # 检测 CONTAINER_IMAGE 变量是否存在
        if [ -z "$CONTAINER_IMAGE" ]; then
            echo "错误：CONTAINER_IMAGE 变量未设置"
            exit 1
        fi

        # 检测 ARCHIVE_IMAGE 变量是否存在
        AVAILABLE_IMAGES=($(sudo podman image list --format "{{.Repository}}:{{.Tag}}"))
        if [[ ! " $${AVAILABLE_IMAGES[*]} " =~ " $CONTAINER_IMAGE " ]]; then
            if [ -z "$ARCHIVE_IMAGE" ]; then
                echo "ARCHIVE_IMAGE 变量不存在，podman image不存在，直接拉取镜像 $CONTAINER_IMAGE"
                sudo podman pull ${each.value.pull_flag} "$CONTAINER_IMAGE"
                exit $?
            fi

            # ARCHIVE_IMAGE 变量存在，检测文件是否存在
            if [ -f "$ARCHIVE_IMAGE" ]; then
                echo "镜像存档文件 $ARCHIVE_IMAGE 存在，正在加载镜像..."
                sudo podman load -i "$ARCHIVE_IMAGE"
                exit $?
            fi

            # 文件不存在，检测文件所在目录是否存在
            archive_dir=$(dirname "$ARCHIVE_IMAGE")
            if [ ! -d "$archive_dir" ]; then
                echo "目录 $archive_dir 不存在，正在创建..."
                sudo mkdir -p "$archive_dir"
                if [ $? -ne 0 ]; then
                    echo "错误：无法创建目录 $archive_dir"
                    exit 1
                fi
            fi

            # 拉取镜像并保存到指定路径
            echo "拉取镜像 $CONTAINER_IMAGE 并保存到 $ARCHIVE_IMAGE"
            sudo podman pull ${each.value.pull_flag} "$CONTAINER_IMAGE"
            if [ $? -eq 0 ]; then
                sudo podman save -o "$ARCHIVE_IMAGE" "$CONTAINER_IMAGE"
                exit $?
            else
                echo "错误：拉取镜像失败"
                exit 1
            fi
        fi
      EOT
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo podman image rm ${self.triggers.image}"
    ]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "vyos_config_block_tree" "container_network" {
  count = var.network == null ? 0 : 1
  path  = "container network ${var.network.name}"

  configs = {
    "prefix" = "${var.network.cidr_prefix}"
  }
}

resource "vyos_config_block_tree" "container_workload" {
  depends_on = [
    null_resource.load_image,
    vyos_config_block_tree.container_network,
  ]
  for_each = {
    for workload in var.workloads : workload.name => workload
  }

  path = "container name ${each.value.name}"

  configs = merge({
    "image" = "${each.value.image}"
  }, each.value.others)
}
