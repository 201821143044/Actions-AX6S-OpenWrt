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

# 替换默认IP
sed -i 's#192.168.1.1#192.168.0.1#g' package/base-files/files/bin/config_generate

# 替换bind
rm -rf feeds/packages/net/bind
wget https://github.com/coolsnowwolf/packages/archive/057aca5ae5c63e9fe545b07045ed24624bbad950.zip -O OldPackages.zip
unzip OldPackages.zip
cp -r packages-057aca5ae5c63e9fe545b07045ed24624bbad950/net/bind feeds/packages/net/
rm -rf OldPackages.zip packages-057aca5ae5c63e9fe545b07045ed24624bbad950

# 移除 openwrt feeds 自带的番茄核心包
rm -rf feeds/packages/net/xray-core
rm -rf feeds/packages/net/v2ray-geodata
rm -rf feeds/packages/net/sing-box
rm -rf feeds/packages/net/chinadns-ng
rm -rf feeds/packages/net/dns2socks
rm -rf feeds/packages/net/dns2tcp
rm -rf feeds/packages/net/microsocks
cp -r feeds/helloworld/xray-core feeds/packages/net
cp -r feeds/helloworld/v2ray-geodata feeds/packages/net
cp -r feeds/helloworld/sing-box feeds/packages/net
cp -r feeds/helloworld/chinadns-ng feeds/packages/net
cp -r feeds/helloworld/dns2socks feeds/packages/net
cp -r feeds/helloworld/dns2tcp feeds/packages/net
cp -r feeds/helloworld/microsocks feeds/packages/net

# 修改golang源码以编译xray1.8.8+版本
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang
# sed -i '/-linkmode external \\/d' feeds/packages/lang/golang/golang-package.mk

# 克隆 coolsnowwolf 的 luci 和 packages 仓库
git clone https://github.com/coolsnowwolf/luci.git coolsnowwolf-luci
git clone https://github.com/coolsnowwolf/packages.git coolsnowwolf-packages

# 替换luci-app-zerotier和luci-app-frpc
rm -rf feeds/luci/applications/{luci-app-zerotier,luci-app-frpc}
cp -r coolsnowwolf-luci/applications/{luci-app-zerotier,luci-app-frpc} feeds/luci/applications

# 替换zerotier、frp 和kcptun
rm -rf feeds/packages/net/{zerotier,frp,kcptun}
cp -r coolsnowwolf-packages/net/{zerotier,frp,kcptun} feeds/packages/net

# 修改frp版本为官网最新v0.62.1 https://github.com/fatedier/frp
rm -rf feeds/packages/net/frp
wget https://github.com/coolsnowwolf/packages/archive/0f7be9fc93d68986c179829d8199824d3183eb60.zip -O OldPackages.zip
unzip OldPackages.zip
cp -r packages-0f7be9fc93d68986c179829d8199824d3183eb60/net/frp feeds/packages/net/
rm -rf OldPackages.zip packages-0f7be9fc93d68986c179829d8199824d3183eb60s
sed -i 's/PKG_VERSION:=0.53.2/PKG_VERSION:=0.62.1/' feeds/packages/net/frp/Makefile
sed -i 's/PKG_HASH:=ff2a4f04e7732bc77730304e48f97fdd062be2b142ae34c518ab9b9d7a3b32ec/PKG_HASH:=d0513f1c08f7a6b31f91ddeca64ccdec43726c20d20103de5220055daa04b903/' feeds/packages/net/frp/Makefile

# 删除克隆的 coolsnowwolf-luci 和 coolsnowwolf-packages 仓库
rm -rf coolsnowwolf-luci
rm -rf coolsnowwolf-packages

# 添加luci-app-openclash
wget https://codeload.github.com/vernesong/OpenClash/zip/refs/heads/master -O OpenClash.zip
unzip OpenClash.zip
cp -r OpenClash-master/luci-app-openclash package/
rm -rf OpenClash.zip OpenClash-master
# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/luci-app-openclash/tools/po2lmo
make && sudo make install
popd
