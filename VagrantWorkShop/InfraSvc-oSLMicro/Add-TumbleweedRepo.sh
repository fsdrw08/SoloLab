REPO=`zypper lr -d | grep tumbleweed`
if [[ ! $REPO =~ "tumbleweed"  ]]
then
    sudo zypper ar -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/tumbleweed/repo/oss/' tuna-Tumbleweed-oss
fi
sudo zypper ref
sudo transactional-update --non-interactive -c pkg in helm