#!/bin/bash
set -euo pipefail

SDK_CHROOT="$PLATFORM_SDK_ROOT/sdk-chroot"
HABUILD_CHROOT="/srv/sailfishos/sdks/ubuntu"
PARENTROOT_ANDROID="/parentroot$ANDROID_ROOT"

echo "=== Building hybris-boot and hybris-recovery ==="

# Build commands to run inside HABUILD chroot
# We create a fake sudo because the chroot's sudo is broken
BUILD_CMDS=$(cat <<'CMDEOF'
set -e
# Fake sudo to avoid ownership errors
mkdir -p /tmp/fakesudo
cat > /tmp/fakesudo/sudo << 'SUDOEOF'
#!/bin/bash
exec "$@"
SUDOEOF
chmod +x /tmp/fakesudo/sudo
export PATH="/tmp/fakesudo:$PATH"

cd /parentroot/home/user/hadk
source build/envsetup.sh
lunch lineage_tissot-userdebug
make bootimage -j$(nproc)
make recoveryimage -j$(nproc)
CMDEOF
)

echo "Launching build inside HABUILD chroot..."
echo "$BUILD_CMDS" | sudo "$SDK_CHROOT" ubu-chroot -r "$HABUILD_CHROOT" bash

if [ $? -ne 0 ]; then
  echo "BUILD FAILED"
  exit 1
fi

echo "Build succeeded. Checking output files..."
ls -lh "$ANDROID_ROOT/out/target/product/$DEVICE/hybris-boot.img" 2>/dev/null || echo "hybris-boot.img not found"
ls -lh "$ANDROID_ROOT/out/target/product/$DEVICE/hybris-recovery.img" 2>/dev/null || echo "hybris-recovery.img not found"
