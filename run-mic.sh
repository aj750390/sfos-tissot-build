#!/bin/bash
set -euo pipefail

source tissot.env

echo "=== Build script started ==="
echo "Device: $DEVICE"
echo "Android root: $ANDROID_ROOT"
echo "Release: $RELEASE"
echo "Arch: $PORT_ARCH"
echo ""

# Check if Android source is mounted
if [ -d "$ANDROID_ROOT" ]; then
    echo "Android source found – HAL build stage ready"
else
    echo "Android source not mounted – skipping HAL build"
fi

echo "Checking mic..."
mic --version || {
    echo "mic not found, installing..."
    sudo zypper install mic
}

echo ""
echo "=== Starting mic image creation ==="
sudo mic create fs \
    --arch=$PORT_ARCH \
    --tokenmap=RELEASE:$RELEASE,ARCH:$PORT_ARCH \
    --record-usage \
    --pkgmgr=zypper \
    --copy-kernel \
    "Jolla-@RELEASE@-tissot-@ARCH@.ks"

echo "=== Build script finished ==="
