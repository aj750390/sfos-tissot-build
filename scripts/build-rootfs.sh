#!/bin/bash
set -euo pipefail

SDK_CHROOT="$PLATFORM_SDK_ROOT/sdk-chroot"
HABUILD_CHROOT="/srv/sailfishos/sdks/ubuntu"
PARENTROOT_ANDROID="/parentroot$ANDROID_ROOT"

echo "=== Building hybris‑hal system image (if missing) ==="

# Check if hybris-hal.img already exists
if [ -f "$ANDROID_ROOT/out/target/product/$DEVICE/hybris-hal.img" ]; then
    echo "hybris-hal.img already exists. Skipping build."
else
    echo "hybris-hal.img not found. Building it now…"
    CMDS=$(cat <<'CMDEOF'
set -e
cd /parentroot/home/user/hadk
source build/envsetup.sh
lunch lineage_tissot-userdebug
make hybris-hal -j$(nproc)
CMDEOF
)
    echo "$CMDS" | sudo "$SDK_CHROOT" ubu-chroot -r "$HABUILD_CHROOT" bash
    if [ $? -ne 0 ]; then
        echo "Building hybris-hal failed. You may need to build it manually."
        exit 1
    fi
fi

# Copy build artifacts to the workspace output directory (passed as IMAGE_DIR)
OUTPUT_DIR="${IMAGE_DIR:-/tmp/images}"
mkdir -p "$OUTPUT_DIR"
cp -v -n "$ANDROID_ROOT/out/target/product/$DEVICE/hybris-boot.img"  "$OUTPUT_DIR/" 2>/dev/null || true
cp -v -n "$ANDROID_ROOT/out/target/product/$DEVICE/hybris-recovery.img" "$OUTPUT_DIR/" 2>/dev/null || true
cp -v -n "$ANDROID_ROOT/out/target/product/$DEVICE/hybris-hal.img" "$OUTPUT_DIR/" 2>/dev/null || true
cp -v -n "$ANDROID_ROOT/out/target/product/$DEVICE/system.img" "$OUTPUT_DIR/" 2>/dev/null || true

echo "Contents of $OUTPUT_DIR:"
ls -lh "$OUTPUT_DIR/"
