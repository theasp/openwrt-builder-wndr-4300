#!/bin/bash

set -ex

export http_proxy=http://localhost:3128

SCRIPT=$(readlink -f "$0")
TOPDIR=$(dirname "$SCRIPT")

URL="https://downloads.openwrt.org/chaos_calmer/15.05/ar71xx/nand/OpenWrt-ImageBuilder-15.05-ar71xx-nand.Linux-x86_64.tar.bz2"
FILE=$(basename $URL)
DIR=${FILE%.tar.bz2}

PROFILE=WNDR4300

PACKAGES="bash bind-host iftop less libiwinfo-lua liblua libubus-lua
          libuci-lua lua luci luci-app-cshark luci-app-ddns
          luci-app-diag-core luci-app-diag-devinfo luci-app-firewall
          luci-app-ntpc luci-app-openvpn luci-app-sqm
          luci-app-statistics luci-app-upnp luci-app-vnstat
          luci-app-watchcat luci-app-wol luci-base luci-lib-ip
          luci-lib-nixio luci-mod-admin-full luci-proto-ipv6
          luci-proto-ppp luci-ssl luci-theme-bootstrap rpcd nmap-ssl
          rsync uhttpd uhttpd-mod-ubus wget zile"

if [ ! -e $FILE ]; then
    wget $URL
fi

mkdir -p build
cd build

if [ ! -e $DIR ]; then
    tar xvfj $TOPDIR/$FILE

    cd $DIR

    for patch in ../patches/*.patch; do
        patch -p1 < $patch
    done
    
    cd ..
fi

cd $DIR
make image PROFILE="$PROFILE" PACKAGES="$(echo $PACKAGES)"
cp bin/ar71xx/*.{tar,img} $TOPDIR

cd $TOPDIR
echo rm -r build

