$tempDir=\"${path.root}/.terraform/tmp/${local.tempDir}\"
$int_desc        = "MGMT"
$int_addr        = "192.168.255.1"
$int_cidr        = "192.168.255.0/24"
$dhcp_start      = "192.168.255.100"
$dhcp_stop       = "192.168.255.200"
$dns_forward_1   = "223.5.5.5"
$dns_forward_2   = "223.6.6.6"
$api_key_id      = "MY-HTTPS-API-ID"
$api_key_content = "MY-HTTPS-API-PLAINTEXT-KEY"
$api_fqdn        = "vyos-api.mgmt.sololab"
$local_hostname  = "VyOS-140"
$user_ssh_key    = "AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ=="
$ntp_server      = "cn.ntp.org.cn"
$time_zone       = "Asia/Shanghai"
$root_ca = Get-Content -Path "..\SoloLab\TerraformWor"
$templateUserData=@"
#cloud-config
# https://github.com/ahpnils/lab-as-code/blob/be47a0d8aabf66b38f718de35546411eb60c879b/cloud-init/isp1router1/user-data#L4
# https://docs.vyos.io/en/stable/automation/cloud-init.html
# https://cloudinit.readthedocs.io/en/latest/reference/modules.html#disk-setup
# https://cloudinit.readthedocs.io/en/latest/reference/examples.html#disk-setup
disk_setup:
  /dev/sdb:
    table_type: gpt
    layout: True
    overwrite: False
fs_setup:
  - label: data
    filesystem: "ext4"
    device: "/dev/sdb1"
    partition: auto
    overwrite: false
# https://cloudinit.readthedocs.io/en/latest/reference/examples.html#adjust-mount-points-mounted
# https://zhuanlan.zhihu.com/p/250658106
mounts:
  - [/dev/disk/by-label/data, /mnt/data, auto, "nofail,exec"]
mount_default_fields: [None, None, "auto", "nofail", "0", "2"]

# !!! one command per line
# !!! if command ends in a value, it must be inside single quotes
# !!! a single-quote symbol is not allowed inside command or value
# to debug, refer
# https://forum.vyos.io/t/errors-when-trying-to-upgrade-a-working-configuration-from-1-2-5-to-1-3-rolling-lastest-build/5395/6
vyos_config_commands:
  # Interface
  - set interfaces ethernet eth0 address 'dhcp'
  - set interfaces ethernet eth0 description 'WAN'
  - set interfaces ethernet eth1 address '${int_addr}/24'
  - set interfaces ethernet eth1 description '${int_desc}'
  # Service
  # DHCP server for local network
  - set service dhcp-server shared-network-name ${int_desc} subnet ${int_cidr} range 0 start '${dhcp_start}'
  - set service dhcp-server shared-network-name ${int_desc} subnet ${int_cidr} range 0 stop '${dhcp_stop}'
  - set service dhcp-server shared-network-name ${int_desc} subnet ${int_cidr} name-server '${int_addr}'
  - set service dhcp-server shared-network-name ${int_desc} subnet ${int_cidr} default-router '${int_addr}'
  - set service dhcp-server shared-network-name ${int_desc} subnet ${int_cidr} domain-name 'sololab'
  - set service dhcp-server shared-network-name ${int_desc} authoritative
  - set service dhcp-server shared-network-name ${int_desc} ping-check
  - set service dhcp-server hostfile-update
  - set service dhcp-server host-decl-name
  # DNS
  - set service dns forwarding cache-size '0'
  - set service dns forwarding listen-address '${int_addr}'
  - set service dns forwarding allow-from '${int_cidr}'
  - set service dns forwarding name-server '${dns_forward_1}'
  - set service dns forwarding name-server '${dns_forward_2}'
  # ssh
  - set service ssh port '22'
  # import ca and cert for vyos api
#   - set pki ca sololab certificate '${ca_cert}'
#   - set pki certificate vyos certificate '${vyos_cert}'
#   - set pki certificate vyos private key '${vyos_key}'
#   # config vyos api
#   - set service https certificates ca-certificate 'sololab'
#   - set service https certificates certificate 'vyos'
#   - set service https listen-address '${int_addr}'
#   - set service https port '8443'
#   - set service https api keys id ${api_key_id} key '${api_key_content}'
#   # dns record for vyos api
#   - set system static-host-mapping host-name ${api_fqdn} inet '${int_addr}'
#   # load-balancing reverse-proxy for vyos api
#   - set load-balancing reverse-proxy service http listen-address '${int_addr}'
#   - set load-balancing reverse-proxy service http port '80'
#   - set load-balancing reverse-proxy service http mode 'http'
#   # - set load-balancing reverse-proxy service https listen-address '${int_addr}'
#   # - set load-balancing reverse-proxy service https port '443'
#   # - set load-balancing reverse-proxy service https mode 'http'
#   - set load-balancing reverse-proxy service tcp443 listen-address '${int_addr}'
#   - set load-balancing reverse-proxy service tcp443 port '443'
#   - set load-balancing reverse-proxy service tcp443 mode 'tcp'
#   - set load-balancing reverse-proxy service tcp443 tcp-request inspect-delay '5000'
#   - set load-balancing reverse-proxy service tcp443 rule 10 ssl 'req-ssl-sni'
#   - set load-balancing reverse-proxy service tcp443 rule 10 domain-name '${api_fqdn}'
#   - set load-balancing reverse-proxy service tcp443 rule 10 set backend 'vyos-api'
#   - set load-balancing reverse-proxy backend vyos-api balance 'round-robin'
#   - set load-balancing reverse-proxy backend vyos-api mode 'tcp'
#   - set load-balancing reverse-proxy backend vyos-api server vyos address '${int_addr}'
#   - set load-balancing reverse-proxy backend vyos-api server vyos port '8443'
  # System
  # hostname
  - set system host-name '${local_hostname}'
  # auth config
  - set system login user vyos authentication plaintext-password 'vyos'
  - set system login user vyos authentication public-keys vagrant key '${user_ssh_key}'
  - set system login user vyos authentication public-keys vagrant type 'ssh-rsa'
  # name server
  - set system name-server '${int_addr}'
  # ntp
  - set system ntp server '${ntp_server}'
  # timezone
  - set system time-zone '${time_zone}'
  # fix /dev/ttyS0: not a tty https://forum.vyos.io/t/dev-ttys0-not-a-tty/9642
  - delete system console device 'ttyS0'

write_files:
  - path: /tmp/finalConfig.sh
    owner: root:vyattacfg
    permissions: "0775"
    content: |
      #!/bin/vbash
      # Ensure that we have the correct group or we'll corrupt the configuration
      if [ "`$(id -g -n)" != 'vyattacfg' ] ; then
          exec sg vyattacfg -c "/bin/vbash `$(readlink -f $0) $@"
      fi

      source /opt/vyatta/etc/functions/script-template
      configure

      # https://minbx.com/tipslab/27/
      # https://forum.tinyserve.com/d/6-build-a-gateway-dns-server-with-v2ray-on-vyos-to-across-gfw
      set nat destination rule 10 description 'CLASH FORWARD'
      set nat destination rule 10 inbound-interface name 'eth1'
      set nat destination rule 10 protocol 'tcp_udp'
      set nat destination rule 10 destination port '80,443'
      set nat destination rule 10 source address '${int_cidr}'
      set nat destination rule 10 translation address '${int_addr}'
      set nat destination rule 10 translation port '7892'


      commit
      save
  - path: /usr/local/share/ca-certificates/sololab.crt
    owner: root:root
    permissions: "0644"
    content: |
      `${indent(6, root_ca)}
"@
$filename="user-data"

mkdir -p $tempDir
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines((Join-Path -Path $tempDir -ChildPath $filename), $content, $Utf8NoBomEncoding)

oscdimg.exe ./.terraform/tmp/$tempDir $isoName -j2 -lcidata

# 定义虚拟机名称和ISO文件路径
$VMName = "VyOS14x-G2"
$IsoPath = "c:\test.iso"

# 检查ISO文件是否存在
if (Test-Path $IsoPath) {
    # 获取虚拟机对象
    $VM = Get-VM -Name $VMName -ErrorAction Stop

    # 检查虚拟机是否已经有一个光驱挂载
    # $DVDDrive = Get-VMScsiController -VM $VM | Get-VMDvdDrive | Where-Object {$_.ControllerLocation -eq 1 -and $_.ControllerNumber -eq 0}
    $DVDDrive = Get-VMDvdDrive -VM $VM

    if ($DVDDrive) {
        # 设置光驱的ISO路径
        Set-VMDvdDrive -VM $VM -Path $IsoPath
        Write-Host "ISO has been mounted to the VM."
    } else {
        Write-Host "No DVD drive found for the VM, Create one"
        Add-VMDvdDrive -VM $VM
    }
} else {
    Write-Host "ISO file does not exist at the specified path."
}