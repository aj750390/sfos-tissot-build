#!/bin/bash
set -euo pipefail

SDK_CHROOT="$PLATFORM_SDK_ROOT/sdk-chroot"
HABUILD_CHROOT="/srv/sailfishos/sdks/ubuntu"
PARENTROOT_ANDROID="/parentroot$ANDROID_ROOT"

echo "=== Building hybris-boot and hybris-recovery ==="

# Build commands to run inside HABUILD chroot
CMDS=$(cat <<'CMDEOF'
set +e  # Don't exit on errors (init scripts may have warnings)
# Temporarily disable sudo during initialization
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Fix any lingering sudo issues
chown root:root /etc/sudo.conf /usr/bin/sudo 2>/dev/null
chmod 4755 /usr/bin/sudo 2>/dev/null

# Move to Android source
cd /parentroot/home/user/hadk || exit 1

# Build
set -e  # Re-enable exit on errors for the build
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
