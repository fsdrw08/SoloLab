# # config static ip
# # https://docs.fedoraproject.org/en-US/fedora-coreos/sysconfig-network-configuration/#_disabling_automatic_configuration_of_ethernet_devices
# data "ignition_file" "disable_dhcp" {
#   path      = "/etc/NetworkManager/conf.d/noauto.conf"
#   mode      = 420
#   overwrite = true
#   content {
#     content = <<EOT
# [main]
# # Do not do automatic (DHCP/SLAAC) configuration on ethernet devices
# # with no other matching connections.
# no-auto-default=*
# EOT
#   }
# }

# # https://docs.fedoraproject.org/en-US/fedora-coreos/sysconfig-network-configuration/#_configuring_a_static_ip
# data "ignition_file" "eth0" {
#   count     = local.count
#   path      = "/etc/NetworkManager/system-connections/eth0.nmconnection"
#   mode      = 384
#   overwrite = true
#   content {
#     content = <<EOT
# [connection]
# id=eth0
# type=ethernet
# interface-name=eth0

# [ipv4]
# method=manual
# address1=192.168.255.2${count.index + 0}/24,192.168.255.1
# dns=192.168.255.1
# EOT
#   }
# }
