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

# https://mirrors.tuna.tsinghua.edu.cn/help/fedora/
data "ignition_file" "tuna_fedora_repo" {
  path      = "/etc/yum.repos.d/fedora.repo"
  mode      = 420 # oct 644 -> dec 420
  overwrite = true
  content {
    content = <<EOT
[fedora]
name=Fedora $releasever - $basearch
failovermethod=priority
baseurl=https://mirrors.tuna.tsinghua.edu.cn/fedora/releases/$releasever/Everything/$basearch/os/
metadata_expire=28d
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch
skip_if_unavailable=False
    EOT
  }
}
data "ignition_file" "tuna_fedora_updates_repo" {
  path      = "/etc/yum.repos.d/fedora-updates.repo"
  mode      = 420 # oct 644 -> dec 420
  overwrite = true
  content {
    content = <<EOT
[updates]
name=Fedora $releasever - $basearch - Updates
failovermethod=priority
baseurl=https://mirrors.tuna.tsinghua.edu.cn/fedora/updates/$releasever/Everything/$basearch/
enabled=1
gpgcheck=1
metadata_expire=6h
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch
skip_if_unavailable=False
    EOT
  }
}
data "ignition_file" "disable_fedora_updates_archive_repo" {
  path      = "/etc/yum.repos.d/fedora-updates-archive.repo"
  mode      = 420 # oct 644 -> dec 420
  overwrite = true
  content {
    content = <<EOT
[updates-archive]
name=Fedora $releasever - $basearch - Updates Archive
baseurl=https://fedoraproject-updates-archive.fedoraproject.org/fedora/$releasever/$basearch/
enabled=0
metadata_expire=6h
repo_gpgcheck=0
type=rpm
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch
skip_if_unavailable=True
cost=10000 # default is 1000
    EOT
  }
}
data "ignition_file" "disable_cisco_repo" {
  path      = "/etc/yum.repos.d/fedora-cisco-openh264.repo"
  mode      = 420 # oct 644 -> dec 420
  overwrite = true
  content {
    content = <<EOT
[fedora-cisco-openh264]
name=Fedora $releasever openh264 (From Cisco) - $basearch
metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-cisco-openh264-$releasever&arch=$basearch
type=rpm
enabled=0
metadata_expire=14d
repo_gpgcheck=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch
skip_if_unavailable=True

[fedora-cisco-openh264-debuginfo]
name=Fedora $releasever openh264 (From Cisco) - $basearch - Debug
metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-cisco-openh264-debug-$releasever&arch=$basearch
type=rpm
enabled=0
metadata_expire=14d
repo_gpgcheck=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch
skip_if_unavailable=True

[fedora-cisco-openh264-source]
name=Fedora $releasever openh264 (From Cisco) - $basearch - Source
metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-cisco-openh264-source-$releasever&arch=$basearch
type=rpm
enabled=0
metadata_expire=14d
repo_gpgcheck=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch
skip_if_unavailable=True
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
Environment=RPMS="cockpit-system cockpit-ostree cockpit-podman cockpit-networkmanager cockpit-bridge"
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
