#!/bin/bash
set -euo pipefail

SDK_CHROOT="$PLATFORM_SDK_ROOT/sdk-chroot"
HABUILD_CHROOT="/srv/sailfishos/sdks/ubuntu"
PARENTROOT_ANDROID="/parentroot$ANDROID_ROOT"

echo "=== Building hybris-boot and hybris-recovery ==="

# Commands to run inside HABUILD chroot
# Fix sudo permissions first, then start the build
CMDS=$(cat <<'CMDEOF'
set -e
# Fix broken sudo permissions inside the chroot (we are root here)
chown root:root /etc/sudo.conf /usr/bin/sudo 2>/dev/null || true
chmod 4755 /usr/bin/sudo 2>/dev/null || true

cd /parentroot/home/user/hadk
source build/envsetup.sh
lunch lineage_tissot-userdebug
make bootimage -j$(nproc)
make recoveryimage -j$(nproc)
CMDEOF
)

echo "Launching build inside HABUILD chroot..."
echo "$CMDS" | sudo "$SDK_CHROOT" ubu-chroot -r "$HABUILD_CHROOT" bash

if [ $? -ne 0 ]; then
  echo "BUILD FAILED"
  exit 1
fi

echo "Build succeeded. Checking output files..."
ls -lh "$ANDROID_ROOT/out/target/product/$DEVICE/hybris-boot.img" 2>/dev/null || echo "hybris-boot.img not found"
ls -lh "$ANDROID_ROOT/out/target/product/$DEVICE/hybris-recovery.img" 2>/dev/null || echo "hybris-recovery.img not found"
