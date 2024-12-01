resource "null_resource" "load_image" {
  triggers = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
    image    = var.workload.image
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
        # check image archive from local
        CONTAINER_IMAGE="${var.workload.image}"
        ARCHIVE_IMAGE="${var.workload.local_image}"
        # AVAILABLE_IMAGES=($(sudo podman image list | awk '{ if ( NR > 1  ) { print $1 ":" $2} }'))
        AVAILABLE_IMAGES=($(sudo podman image list --format "{{.Repository}}:{{.Tag}}"))

        if [[ ! " $${AVAILABLE_IMAGES[*]} " =~ " $CONTAINER_IMAGE " ]]; then
          if [[ -n "$ARCHIVE_IMAGE" ]]; then
            echo "Loading image $CONTAINER_IMAGE"
            if [ -f "$ARCHIVE_IMAGE" ]; then
                sudo podman load --input $ARCHIVE_IMAGE
            else
                sudo podman pull $CONTAINER_IMAGE
                if [ -d $(dirname "$ARCHIVE_IMAGE") ]; then
                  sudo mkdir -p $(dirname "$ARCHIVE_IMAGE")
                fi
                sudo podman save -o $ARCHIVE_IMAGE $CONTAINER_IMAGE
                # echo "pull and save the target image to $ARCHIVE_IMAGE first"
                # echo "sudo podman save -o $ARCHIVE_IMAGE $CONTAINER_IMAGE first"
                # exit 1
            fi
          else
            sudo podman pull $CONTAINER_IMAGE
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
}

resource "vyos_config_block_tree" "container_network" {
  count = var.network.create == true ? 1 : 0
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

  path = "container name ${var.workload.name}"

  configs = merge({
    "image" = "${var.workload.image}"
  }, var.workload.others)
}
