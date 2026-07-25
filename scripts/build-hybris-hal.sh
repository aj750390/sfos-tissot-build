#!/bin/bash
set -euo pipefail

SDK_CHROOT="$PLATFORM_SDK_ROOT/sdk-chroot"
HABUILD_CHROOT_INSIDE="/srv/sailfishos/sdks/ubuntu"

echo "=== Building hybris-boot and hybris-recovery ==="

# Switch to the Android source directory inside the SDK + HABUILD chroot
# We run: sdk-chroot ubu-chroot -r <path> bash -c "…"
# The ANDROID_ROOT is /home/user/hadk, but inside the HABUILD chroot it's /parentroot/home/user/hadk
PARENTROOT_ANDROID="/parentroot$ANDROID_ROOT"

COMMANDS="
set -e
cd $PARENTROOT_ANDROID
source build/envsetup.sh
lunch lineage_tissot-userdebug
make bootimage -j\$(nproc)
make recoveryimage -j\$(nproc)
"

echo "Launching build inside HABUILD chroot..."
if ! echo "$COMMANDS" | sudo "$SDK_CHROOT" ubu-chroot -r "$HABUILD_CHROOT_INSIDE" bash; then
  echo "BUILD FAILED"
  exit 1
fi

echo "Build succeeded. Checking output files..."
ls -lh "$ANDROID_ROOT/out/target/product/$DEVICE/hybris-boot.img" 2>/dev/null || echo "hybris-boot.img not found"
ls -lh "$ANDROID_ROOT/out/target/product/$DEVICE/hybris-recovery.img" 2>/dev/null || echo "hybris-recovery.img not found"
