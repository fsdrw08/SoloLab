## install packages
# prepare yum repo
data "ignition_file" "hashicorp_repo" {
  path = "/etc/yum.repos.d/hashicorp.repo"
  mode = 420 # oct 644 -> dec 420
  # source {
  #   source = "https://rpm.releases.hashicorp.com/fedora/hashicorp.repo"
  # }
  # or
  content {
    content = <<EOT
[hashicorp]
name=Hashicorp Stable - $basearch
baseurl=https://rpm.releases.hashicorp.com/fedora/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://rpm.releases.hashicorp.com/gpg
  EOT
  }
}

# https://cockpit-project.org/running.html#coreos
# https://github.com/coreos/fedora-coreos-tracker/issues/681
data "ignition_file" "rpms" {
  path = "/etc/systemd/system/rpm-ostree-install.service.d/rpms.conf"
  mode = 420 # oct 644 -> dec 420
  content {
    content = <<EOT
[Service]
Environment=RPMS="cockpit-system cockpit-ostree cockpit-podman cockpit-networkmanager rclone"
EOT
  }
}

# https://github.com/coreos/fedora-coreos-tracker/issues/681#issuecomment-974301872
data "ignition_systemd_unit" "rpm_ostree" {
  name    = "rpm-ostree-install.service"
  enabled = true
  content = <<EOT
[Unit]
Description=Layer additional rpms
Wants=network-online.target
After=network-online.target
# We run before `zincati.service` to avoid conflicting rpm-ostree transactions.
Before=zincati.service
ConditionPathExists=!/var/lib/%N.stamp
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/rpm-ostree install --apply-live --allow-inactive $RPMS
ExecStart=/bin/touch /var/lib/%N.stamp
[Install]
WantedBy=multi-user.target
EOT
}
