#!/bin/bash
set -euo pipefail

UBUNTU_CHROOT="$PLATFORM_SDK_ROOT/sdks/ubuntu"

# ubu-chroot must be invoked from inside the Platform SDK shell (sdk-chroot),
# and ANDROID_ROOT/DEVICE/VENDOR/PORT_ARCH need to be visible inside that
# nested chroot too, hence re-exporting them in the -c string below.
"$PLATFORM_SDK_ROOT/sdk-chroot" -c "
  ubu-chroot -r '$UBUNTU_CHROOT' bash -lc '
    set -euo pipefail
    export ANDROID_ROOT=\"$ANDROID_ROOT\"
    export DEVICE=\"$DEVICE\"
    export VENDOR=\"$VENDOR\"
    export PORT_ARCH=\"$PORT_ARCH\"
    cd \"\$ANDROID_ROOT\"
    source build/envsetup.sh
    breakfast \$DEVICE
    make -j\$(nproc) hybris-hal
  '
"

OUT_DIR="$ANDROID_ROOT/out/target/product/$DEVICE"
test -f "$OUT_DIR/hybris-boot.img"
test -f "$OUT_DIR/hybris-recovery.img"
echo "hybris-boot.img and hybris-recovery.img built OK at $OUT_DIR"
