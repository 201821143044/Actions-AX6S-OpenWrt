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

# 移除 openwrt feeds 自带的番茄核心包
rm -rf feeds/packages/net/{xray-core,xray-plugin,v2ray-core,v2ray-plugin,v2ray-geodata,sing-box,hysteria,naiveproxy,shadowsocks-rust,tuic-client,microsocks,chinadns-ng,alist,dns2socks,dns2tcp,ipt2socks}
rm -rf feeds/luci/applications/{luci-app-passwall,luci-app-ssr-plus}

# 修改golang源码以编译xray1.8.8+版本
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang
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

# 修改frp版本为官网最新v0.61.0 https://github.com/fatedier/frp
rm -rf feeds/packages/net/frp
wget https://github.com/coolsnowwolf/packages/archive/0f7be9fc93d68986c179829d8199824d3183eb60.zip -O OldPackages.zip
unzip OldPackages.zip
cp -r packages-0f7be9fc93d68986c179829d8199824d3183eb60/net/frp feeds/packages/net/
rm -rf OldPackages.zip packages-0f7be9fc93d68986c179829d8199824d3183eb60s
sed -i 's/PKG_VERSION:=0.53.2/PKG_VERSION:=0.61.0/' feeds/packages/net/frp/Makefile
sed -i 's/PKG_HASH:=ff2a4f04e7732bc77730304e48f97fdd062be2b142ae34c518ab9b9d7a3b32ec/PKG_HASH:=c06a11982ef548372038ec99a6b01cf4f7817a9b88ee5064e41e5132d0ccb7e1/' feeds/packages/net/frp/Makefile

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
