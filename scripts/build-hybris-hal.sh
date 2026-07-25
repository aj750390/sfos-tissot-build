#!/bin/bash
set -euo pipefail

SDK_CHROOT="$PLATFORM_SDK_ROOT/sdk-chroot"
HABUILD_CHROOT_HOST="/srv/sailfishos/sdks/sfossdk/srv/sailfishos/sdks/ubuntu"
HABUILD_CHROOT_INSIDE="/srv/sailfishos/sdks/ubuntu"
PARENTROOT_ANDROID="/parentroot$ANDROID_ROOT"

echo "=== Building hybris-boot and hybris-recovery ==="

# Fix broken sudo permissions inside the HABUILD chroot from the host
echo "Fixing chroot sudo permissions on host..."
sudo chown root:root "$HABUILD_CHROOT_HOST/etc/sudo.conf" "$HABUILD_CHROOT_HOST/usr/bin/sudo" 2>/dev/null || true
sudo chmod 4755 "$HABUILD_CHROOT_HOST/usr/bin/sudo" 2>/dev/null || true

CMDS=$(cat <<'CMDEOF'
set -e
cd /parentroot/home/user/hadk
source build/envsetup.sh
lunch lineage_tissot-userdebug
make bootimage -j$(nproc)
make recoveryimage -j$(nproc)
CMDEOF
)

echo "Launching build inside HABUILD chroot..."
echo "$CMDS" | sudo "$SDK_CHROOT" ubu-chroot -r "$HABUILD_CHROOT_INSIDE" bash

if [ $? -ne 0 ]; then
  echo "BUILD FAILED"
  exit 1
fi

echo "Build succeeded. Checking output files..."
ls -lh "$ANDROID_ROOT/out/target/product/$DEVICE/hybris-boot.img" 2>/dev/null || echo "hybris-boot.img not found"
ls -lh "$ANDROID_ROOT/out/target/product/$DEVICE/hybris-recovery.img" 2>/dev/null || echo "hybris-recovery.img not found"
