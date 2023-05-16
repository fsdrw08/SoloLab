# https://unix.stackexchange.com/questions/728955/why-is-the-root-filesystem-so-small-on-a-clean-fedora-37-install
FS=$(df -h | grep mapper | awk '{print $1}')
echo "resize $FS"

# /dev/mapper/fedora_fedora-root
# https://stackoverflow.com/questions/26305376/resize2fs-bad-magic-number-in-super-block-while-trying-to-open
sudo lvextend -l +100%FREE $FS
sudo fsadm resize $FS