#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 修改连接数
#sed -i 's/net.netfilter.nf_conntrack_max=.*/net.netfilter.nf_conntrack_max=165535/g' package/kernel/linux/files/sysctl-nf-conntrack.conf
#修正连接数（by ベ七秒鱼ベ）
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf


#git clone https://github.com/kiddin9/openwrt-packages.git package/openwrt-packages

#git clone --depth=1 https://github.com/sirpdboy/luci-app-netdata.git package/luci-app-netdata

#添加额外非必须软件包

#添加smartdns
#git clone --depth=1 https://github.com/kiddin9/luci-app-dnsfilter.git package/luci-app-dnsfilter

git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns
git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns.git package/luci-app-smartdns
git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome
git clone --depth=1 https://github.com/yichya/luci-app-xray package/extra/luci-app-xray
