#!/bin/sh
#
# Clash Control Script
#
# Author: sskaje (https://sskaje.me/ https://github.com/sskaje/ubnt-clash)
# Version: 0.1.0
#
# Required commands:
#    curl
#    jq
#    yq
#

CLASH_BINARY=/usr/sbin/clashd
CLASH_RUN_ROOT=/run/clash
CLASH_SUFFIX=
YQ_BINARY=/usr/bin/yq
YQ_SUFFIX=
UI_PATH=/config/clash/dashboard
CLASH_DASHBOARD_URL=https://github.com/Dreamacro/clash-dashboard/archive/refs/heads/gh-pages.tar.gz

CLASH_CONFIG_ROOT=/config/clash

CLASH_DOWNLOAD_NAME=clash.config

if [ -f $CLASH_CONFIG_ROOT/USE_PROXY ]; then
  USE_PROXY=$(<$CLASH_CONFIG_ROOT/USE_PROXY)
  [[ $USE_PROXY -lt 1 ]] && USE_PROXY=1
fi

# Clash premium only support 1 single tun interface named utun.
DEV=utun

CLASH_REPO=Dreamacro/clash
CLASH_REPO_TAG=tags/premium

CLASH_EXECUTABLE=$(cli-shell-api returnEffectiveValue interfaces clash $DEV executable)

if [ "$CLASH_EXECUTABLE" == "meta" ]; then
  CLASH_REPO=MetaCubeX/Clash.Meta
  CLASH_REPO_TAG=latest
fi

hwtype=$(uname -m)
if [[ "$hwtype" == "mips64" ]]; then
  CLASH_SUFFIX="mips64-"
  YQ_SUFFIX="mips64"
elif [[ "$hwtype" == "mips" ]]; then
  CLASH_SUFFIX="mipsle-hardfloat-"
  YQ_SUFFIX="mipsle"
elif [[ "$hwtype" == "aarch64" ]]; then
  echo "Are you using UnifiOS devices?"
  exit
elif [[ "$hwtype" == "x86_64" ]]; then
  # VyOS, amd64 only
  CLASH_SUFFIX="linux-amd64-v3-"
  YQ_SUFFIX="linux_amd64"
else
  echo "Unknown Arch"
  exit -1
fi

mkdir -p $CLASH_RUN_ROOT/$DEV $CLASH_CONFIG_ROOT/$DEV

function check_patch_vyatta()
{
  if [ -z "$(grep 'utun' /opt/vyatta/share/perl5/Vyatta/Interface.pm | grep clash)" ]; then
    # find line with %net_prefix = (
    # insert the "'^utun$' => { path => 'clash' },"

    sed -i.bak "/%net_prefix =/a     '^utun\$' => { path => 'clash' }," /opt/vyatta/share/perl5/Vyatta/Interface.pm
  fi
}

check_patch_vyatta

function help()
{
  cat <<USAGE

Clashctl for UBNT EdgeRouter by sskaje


Usage:
  clashctl.sh command [options]


Commands:
  start [utun]           Start an instance
  stop [utun]            Stop an instance
  restart [utun]         Restart an instance
  purge_cache [utun]     Remove cache.db and restart
  delete [utun]          Delete an instance
  status [utun]          Show instance status
  rehash [utun]          Download config and restart to reload
  reload [utun]          Reload config
  check_config [utun]    Check instance configuration
  show_config [utun]     Show instance configuration
  install                Install
  check_update           Check clash binary version
  check_version          Check clash binary version
  update                 Update clash binary
  update_ui              Download Dashboard UI
  update_db              Download GeoIP Database
  update_yq              Download YQ binary
  cron                   Run cron
  show_version           Show clash binary version
  help                   Show this message


USAGE


}

function http_download()
{
  ASSET_URL=$1

  if [ $(("$USE_PROXY" & 1)) -ne 0 ]; then
    echo "Download will be proxied via p.rst.im" 1>&2
    ASSET_URL=$(echo $ASSET_URL | sed -e 's#github.com#p.rst.im/q/github.com#')
  fi

  TMPFILE=$(mktemp)
  echo curl -L -o "$TMPFILE" $ASSET_URL 1>&2
  curl -L -o "$TMPFILE" $ASSET_URL

  echo "$TMPFILE"
}

function github_download()
{
  REPO=$1
  TAG=$2
  NAME=$3

  API_URL=https://api.github.com/repos/$REPO/releases/$TAG

  if [ $(("$USE_PROXY" & 1)) -ne 0 ]; then
    echo "API will be proxied via p.rst.im" 1>&2
    API_URL=$(echo $API_URL | sed -e 's#api.github.com#p.rst.im/q/api.github.com#')
  fi

  ASSET_URL=$(curl -q -s $API_URL | jq -r '.assets[0] | select(.name == "'$NAME'") | .browser_download_url')

  http_download $ASSET_URL
}


function github_releases()
{
  REPO=$1
  TAG=${2:-latest}

  API_URL=https://api.github.com/repos/$REPO/releases/$TAG

  if [ $(("$USE_PROXY" & 1)) -ne 0 ]; then
    echo "API will be proxied via p.rst.im" 1>&2
    API_URL=$(echo $API_URL | sed -e 's#api.github.com#p.rst.im/q/api.github.com#')
  fi

  ASSET_URL=$(curl -q -s $API_URL | jq -r '.assets')

  echo $ASSET_URL
}


function check_version()
{
  echo "Checking latest binary $CLASH_REPO ($CLASH_REPO_TAG)... " 1>&2

  PACKAGE_NAME=$(github_releases $CLASH_REPO $CLASH_REPO_TAG | jq -r  '.[] | select(.name | contains("'$CLASH_SUFFIX'")) | .name')
  echo "Latest version: " $PACKAGE_NAME 1>&2
}

function install_clash()
{
  echo "Getting asset download URL..." 1>&2
  ASSET_URL=$(github_releases $CLASH_REPO $CLASH_REPO_TAG | jq -r  '.[] | select(.name | contains("'$CLASH_SUFFIX'")) | .browser_download_url')

  TMPFILE=$(http_download $ASSET_URL)

  if [ $? -eq 0 ]; then
    mv "$TMPFILE" "$TMPFILE".gz
    gunzip "$TMPFILE".gz
    chmod +x "$TMPFILE"
    "$TMPFILE" -v | grep "Clash" > /dev/null 2>&1 && sudo mv "$TMPFILE" $CLASH_BINARY
  fi

  rm -f "$TMPFILE"

}

function clash_version()
{
  test -x $CLASH_BINARY && $CLASH_BINARY -v
}

function check_clash_binary()
{
  if [ ! -x $CLASH_BINARY ]; then
    echo "You need to install clash binary first."
    echo "Run: `clashctl.sh install`"
    exit 1
  fi
}

function download_config()
{
  echo "Download Config" 1>&2
  check_clash_binary

  CONFIG_URL=$(cli-shell-api returnEffectiveValue interfaces clash $DEV config-url)

  if [ $(("$USE_PROXY" & 2)) -ne 0 ]; then
    echo "Download will be proxied via p.rst.im" 1>&2
    CONFIG_URL=$(echo $CONFIG_URL | sed -e 's#https://#https://p.rst.im/q/#')
  fi

  TMPFILE=$(mktemp)

  curl -q -s -L -o "$TMPFILE" $CONFIG_URL
  # todo: if executable == clash, check if Country.mmdb exists

  # test config and install, in /run/clash/utun
  $CLASH_BINARY -d $CLASH_RUN_ROOT/$DEV -f $TMPFILE -t | grep 'test is successful' >/dev/null 2>&1 &&
    mv "$TMPFILE" $CLASH_CONFIG_ROOT/$DEV/$CLASH_DOWNLOAD_NAME ||
    echo "Error: Invalid Clash Config: $CONFIG_URL" 1>&2 && rm -f $TMPFILE && exit 1
  #$CLASH_BINARY -d $CLASH_CONFIG_ROOT/$DEV -f $TMPFILE -t | grep 'test is successful' >/dev/null 2>&1 &&  mv "$TMPFILE" $CLASH_CONFIG_ROOT/$DEV/$CLASH_DOWNLOAD_NAME
}

function download_geoip_db()
{
  DB_PATH=$CLASH_CONFIG_ROOT/Country.mmdb

  echo "Downloading Country.mmdb ..." 1>&2
  TMPFILE=$(github_download Dreamacro/maxmind-geoip latest Country.mmdb)

  if [ $? -eq 0 ]; then
    sudo mv "$TMPFILE" $DB_PATH
  fi
  rm -f "$TMPFILE"

  if [ "$CLASH_EXECUTABLE" == "meta" ]; then
    DB_PATH=$CLASH_CONFIG_ROOT/geosite.dat

    echo "Downloading Geosite.dat ..." 1>&2
    TMPFILE=$(github_download Loyalsoldier/v2ray-rules-dat latest geosite.dat)
    # todo: verify hash

    if [ $? -eq 0 ]; then
      sudo mv "$TMPFILE" $DB_PATH
    fi
    rm -f "$TMPFILE"
  fi
}

function copy_geoip_db()
{
  echo "Installing GeoIP DB..." 1>&2

  DB_PATH=$CLASH_CONFIG_ROOT/Country.mmdb

  if [ -f $DB_PATH ]; then
    # DO NOT COPY
    ln -s $DB_PATH $CLASH_RUN_ROOT/$DEV/Country.mmdb
  else
    echo "GeoIP DB Not found, clash will download it, if it's too slow, try USE_PROXY=1 $0 update_db " 1>&2
  fi

  if [ "$CLASH_EXECUTABLE" == "meta" ]; then
    echo "Installing GeoSite DB..." 1>&2

    DB_PATH=$CLASH_CONFIG_ROOT/geosite.dat

    if [ -f $DB_PATH ]; then
      # DO NOT COPY
      ln -s $DB_PATH $CLASH_RUN_ROOT/$DEV/geosite.dat
    else
      echo "GeoSite DB Not found, clash will download it, if it's too slow, try USE_PROXY=1 $0 update_db " 1>&2
    fi
  fi
}

function check_copy_geoip_db()
{
  if [ ! -f $CLASH_RUN_ROOT/$DEV/Country.mmdb ] || [ "$CLASH_EXECUTABLE" == "meta" ] && [ ! -f $CLASH_RUN_ROOT/$DEV/geosite.dat ] ; then
    copy_geoip_db
  fi
}

function install_yq()
{
  echo "Installing yq..." 1>&2
  YQ_ASSET_URL=$(github_releases mikefarah/yq latest | jq -r  '.[] | select(.name | endswith("'$YQ_SUFFIX'")) | .browser_download_url')

  TMPFILE=$(http_download $YQ_ASSET_URL)

  if [ $? -eq 0 ]; then
    chmod +x "$TMPFILE"
    # extract
    "$TMPFILE" -V | grep "yq" > /dev/null 2>&1 && sudo mv "$TMPFILE" $YQ_BINARY && echo "yq installed to $YQ_BINARY" 1>&2
  fi

  if [ -x $YQ_BINARY ]; then
    # strip binary for better performance
    if [ -x /usr/bin/strip ]; then
      /usr/bin/strip $YQ_BINARY
    fi
  else
    echo "YQ not installed"
    exit 1
  fi
  rm -f "$TMPFILE"
}

function yq_version()
{
  $YQ_BINARY -V
}

function install_ui()
{
  echo "Downloading UI..." 1>&2
  TMPFILE=$(http_download $CLASH_DASHBOARD_URL)

  if [ $? -eq 0 ]; then
    # extract
    echo "Installing UI to $UI_PATH" 1>&2
    mkdir -p $UI_PATH
    tar --strip-components=1 -xv -C $UI_PATH -f "$TMPFILE"
  fi
  rm -f "$TMPFILE"
}

function generate_config()
{
  if [ ! -f $CLASH_CONFIG_ROOT/$DEV/$CLASH_DOWNLOAD_NAME ]; then
    download_config
  fi

  # /config/clash/templates => /config/clash/utun
  for i in $(ls $CLASH_CONFIG_ROOT/templates/*.yaml); do
    f=$(basename $i)
    if [ ! -f $CLASH_CONFIG_ROOT/$DEV/$f ]; then
      cp $CLASH_CONFIG_ROOT/templates/$f $CLASH_CONFIG_ROOT/$DEV/
    fi
  done

  rm -f $CLASH_RUN_ROOT/$DEV/config.yaml

  # manually setting order to ensure local rules correctly inserted before downloaded rules
  config_files=($CLASH_CONFIG_ROOT/$DEV/*.yaml $CLASH_CONFIG_ROOT/$DEV/rulesets/*.yaml $CLASH_CONFIG_ROOT/$DEV/$CLASH_DOWNLOAD_NAME $CLASH_CONFIG_ROOT/$DEV/*.yaml.overwrite)

  if [ "$CLASH_EXECUTABLE" == "meta" ]; then
    config_files+=($CLASH_CONFIG_ROOT/$DEV/meta.d/*.yaml)
  fi
  $YQ_BINARY eval-all --from-file /usr/share/ubnt-clash/one.yq ${config_files[@]} > $CLASH_RUN_ROOT/$DEV/config.yaml


  # manually setting order to ensure local rules correctly inserted before downloaded rules
#  yq eval-all --from-file /usr/share/ubnt-clash/one.yq \
#    $CLASH_CONFIG_ROOT/$DEV/*.yaml \
#    $CLASH_CONFIG_ROOT/$DEV/rulesets/*.yaml \
#    $CLASH_CONFIG_ROOT/$DEV/$CLASH_DOWNLOAD_NAME \
#    $CLASH_CONFIG_ROOT/$DEV/*.yaml.overwrite \
#    > $CLASH_RUN_ROOT/$DEV/config.yaml

}

function show_config()
{
  cli-shell-api showCfg interfaces clash $DEV
}

function start()
{
  check_clash_binary

  if [ -f $CLASH_RUN_ROOT/$DEV/clash.pid ]; then
    if read pid < "$CLASH_RUN_ROOT/$DEV/clash.pid" && ps -p "$pid" > /dev/null 2>&1; then
      echo "Clash $DEV is running." 1>&2
      return 0
    else
      rm -f $CLASH_RUN_ROOT/$DEV/clash.pid
    fi
  fi

  cli-shell-api existsActive interfaces clash $DEV disable

  if [ $? -eq 0 ]; then
    echo "$DEV disabled" 1>&2
    exit;
  fi


  # pre-up
  [ -x $CLASH_CONFIG_ROOT/$DEV/scripts/pre-up.sh ] && . $CLASH_CONFIG_ROOT/$DEV/scripts/pre-up.sh

  check_copy_geoip_db

  generate_config

  ( umask 0; sudo setsid sh -c "$CLASH_BINARY -d $CLASH_RUN_ROOT/$DEV > /tmp/clash_$DEV.log 2>&1 & echo \$! > $CLASH_RUN_ROOT/$DEV/clash.pid" )

  # post-up
  [ -x $CLASH_CONFIG_ROOT/$DEV/scripts/post-up.sh ] && . $CLASH_CONFIG_ROOT/$DEV/scripts/post-up.sh

  touch $CLASH_RUN_ROOT/$DEV/checked
}


function stop()
{
  if [ -f $CLASH_RUN_ROOT/$DEV/clash.pid ]; then
    # pre-down
    [ -x $CLASH_CONFIG_ROOT/$DEV/scripts/pre-down.sh ] && . $CLASH_CONFIG_ROOT/$DEV/scripts/pre-down.sh
    sudo kill $(cat $CLASH_RUN_ROOT/$DEV/clash.pid)
    rm -f $CLASH_RUN_ROOT/$DEV/clash.pid
    # post-down
    [ -x $CLASH_CONFIG_ROOT/$DEV/scripts/post-down.sh ] && . $CLASH_CONFIG_ROOT/$DEV/scripts/post-down.sh
  fi
}

function delete()
{
  stop
  sudo rm -rf $CLASH_RUN_ROOT/$DEV $CLASH_CONFIG_ROOT/$DEV
}

function check_status()
{
  if [ ! -f $CLASH_RUN_ROOT/$DEV/clash.pid ]; then
    echo "Clash $DEV is not running". 1>&2
    return 2
  fi

  if read pid < "$CLASH_RUN_ROOT/$DEV/clash.pid" && ps -p "$pid" > /dev/null 2>&1; then
    echo "Clash $DEV is running." 1>&2
    return 0
  else
    echo "Clash $DEV is not running but $CLASH_RUN_ROOT/$DEV/clash.pid exists." 1>&2
    return 1
  fi
}

function run_cron()
{
  # read device config
  for device in $(cli-shell-api listActiveNodes interfaces clash); do
    eval "device=($device)"
    echo "Processing Device $device" 1>&2

    cli-shell-api existsActive interfaces clash $DEV disable

    if [ $? -eq 0 ]; then
      echo "$DEV disabled" 1>&2
      continue;
    fi

    now_time=$(date +'%s')

    # default to 86400
    update_interval=$(cli-shell-api returnEffectiveValue interfaces clash $device update-interval)
    config_mtime=$(stat -c %Y $CLASH_CONFIG_ROOT/$DEV/$CLASH_DOWNLOAD_NAME)
    diff_in_seconds=$(expr $now_time - $config_mtime)
    REHASHED=""

    if [ $diff_in_seconds -gt $update_interval ];then
      download_config $device
      REHASHED="1"
    else
      echo "No need to update config" 1>&2
    fi

    if [ -f "$CLASH_RUN_ROOT/$DEV/clash.pid" ] && read pid < "$CLASH_RUN_ROOT/$DEV/clash.pid" && ps -p "$pid" > /dev/null 2>&1; then
      echo "Clash $DEV is running." 1>&2

      if [ "$REHASHED" == "1" ]; then
        # configuration need to be re-generated
        generate_config
        # stop $device
        # start $device
        echo "Reloading $DEV via REST API"
        python /usr/bin/clashmonitor.py reload $device
      fi

      check_interval=$(cli-shell-api returnEffectiveValue interfaces clash $device check-interval)
      checkfile_mtime=$(stat -c %Y $CLASH_RUN_ROOT/$device/checked)
      diff_in_seconds=$(expr $now_time - $checkfile_mtime)
      REHASHED=""
      if [ $diff_in_seconds -gt $check_interval ];then
        # run monitor
        date >> /tmp/clash_monitor.log
        python /usr/bin/clashmonitor.py monitor $device >> /tmp/clash_monitor.log
        touch $CLASH_RUN_ROOT/$device/checked
      fi
    else
      date >> /tmp/clash_monitor.log
      echo "Monitor starting Clash $DEV" >> /tmp/clash_monitor.log
      mv /tmp/clash_$DEV.log /tmp/clash_$DEV_$(date +"%s").log
      echo "Starting Clash $DEV ." 1>&2
      start
    fi
  done
}

function monitor_test()
{
  python /usr/bin/clashmonitor.py test $DEV
}

function purge_cache()
{
  rm -f $CLASH_RUN_ROOT/$DEV/cache.db
}

case $1 in
  start)
    start
    ;;

  delaystart)
    sleep 5;
    start
    ;;

  stop)
    stop
    ;;

  delete)
    delete
    ;;

  restart)
    stop
    sleep 1
    start
    ;;

  purge_cache)
    purge_cache
    stop
    sleep 1
    start
    ;;

  install)
    install_yq
    download_geoip_db
    install_clash
    install_ui
    ;;

  update_db | install_db)
    download_geoip_db
    ;;
  update_yq | install_yq)
    install_yq
    ;;
  update_ui | install_ui)
    install_ui
    ;;

  update | update_clash | install_clash)
    install_clash
    ;;

  status)
    check_status
    ;;

  test)
    monitor_test
    ;;

  check_update | check_version)
    clash_version
    check_version
    ;;

  show_version | clash_version | version)
    clash_version
    ;;

  yq_version)
    yq_version
    ;;

  check_config)

    ;;

  show_config)
    show_config
    ;;

  reload)
    # re-generate
    generate_config
    python /usr/bin/clashmonitor.py reload $device
    ;;

  rehash)
    download_config

  echo "Restarting clash..." 1>&2
    stop
    sleep 1
    start
    ;;

  generate_config)
    # re-generate for test purpose
    generate_config
    ;;

  cron | monitor)
    (
      flock -e 200
      run_cron
    ) 200>/tmp/clash-monitor.lock
    ;;

  help)
    help
    ;;

  *)
    echo "Invalid Command" 1>&2
    help
    exit 1
    ;;
esac
