#!/bin/bash
#########################################################################
#
# Download recipe for the used chromium packages
# Adapted for both ARM64 and x86_64 (Debian Trixie)
#
#########################################################################
. ../../scripts/rebuilder.lib.sh

# 树莓派官方的旧版本号（保持原样，以防你在其他 ARM 环境下还需要编译）
PKG_VERSION=126.0.6478.164-rpt1

mkdir -p dist/binary
cd dist/binary

rm -rf *.deb*

# 探测当前容器的宿主架构
ARCH=$(dpkg --print-architecture)

if [ "$ARCH" = "amd64" ]; then
    echo "🌐 检测到正在 x86_64 (amd64) 环境下构建，正在从 Debian 官方源抓取原生 Chromium..."
    
    # 使用 apt 仅下载而不到本地安装 chromium 及其多国语言包、核心解码器
    apt-get update
    apt-get download chromium chromium-sandbox chromium-common chromium-l10n 2>/dev/null || true
    
    # 顺便检查一下下载结果
    if [ ! -f chromium_*.deb ] && [ ! -f chromium-common_*.deb ]; then
        echo "❌ 错误: 从 Debian 官方源下载 Chromium 失败！"
        exit 1
    fi
else
    echo "🍓 检测到在 ARM64 环境下构建，维持 moOde 原版树莓派官方源下载逻辑..."
    wget -q "http://archive.raspberrypi.org/debian/pool/main/c/chromium-browser/chromium-browser_${PKG_VERSION}_arm64.deb"
    wget -q "http://archive.raspberrypi.org/debian/pool/main/c/chromium-browser/chromium-browser-l10n_${PKG_VERSION}_all.deb"
    wget -q "http://archive.raspberrypi.org/debian/pool/main/c/chromium-browser/chromium-codecs-ffmpeg-extra_${PKG_VERSION}_arm64.deb"
fi

ls -la
echo "✅ Ready for upload to moode repo"

cd ../../
