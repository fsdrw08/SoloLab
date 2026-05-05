#!/bin/bash

# Check if disk exists
if ! lsblk | grep -q "Disk /dev/sdb"; then
  echo "Disk /dev/sdb not found"
  exit 1
fi

# Check if GPT partition table exists
if sgdisk -p /dev/sdb | grep -q "not present"; then
  echo "Creating GPT partition table on /dev/sdb"
  sgdisk -g /dev/sdb
fi

# Check if data partition exists
if lsblk | grep -q "part /dev/sdb1"; then
  echo "Partition /dev/sdb1 already exists"
else
  echo "Creating data partition on /dev/sdb"
  sgdisk -n 1 /dev/sdb
fi

# Check if file system exists
if ! lsblk -f | grep -q "ext4"; then
  echo "Creating ext4 file system on /dev/sdb1"
  mkfs.ext4 /dev/sdb1
fi

# Check if label exists
if ! blkid /dev/sdb1 | grep -q "data"; then
  echo "Labeling /dev/sdb1 as data"
  e2label /dev/sdb1 data
fi

# Mount the partition on boot
if ! grep -q "/dev/sdb1 /mnt/data ext4 defaults 0 2" /etc/fstab; then
  echo "Mounting /dev/sdb1 to /mnt/data on boot"
  echo "/dev/sdb1 /mnt/data ext4 defaults 0 2" >> /etc/fstab
fi

# Create mount point if it doesn't exist
if [ ! -d "/mnt/data" ]; then
  echo "Creating /mnt/data directory"
  mkdir /mnt/data
fi

# Mount the partition manually
# https://man7.org/linux/man-pages/man8/mount.8.html
if ! mountpoint -q /mnt/data; then
  echo "Mounting /dev/sdb1 to /mnt/data"
  mount /mnt/data
fi

echo "Disk configuration complete"