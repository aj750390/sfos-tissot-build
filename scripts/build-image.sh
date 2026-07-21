#!/bin/bash
set -euo pipefail

# Final packaging step: run mic (inside Platform SDK) against the device's
# kickstart file to produce a flashable Sailfish OS image.

PLATFORM_SDK_ENTER="/srv/hadk/platform-sdk/sdk-chroot"
KICKSTART="droid-config-$DEVICE/sparse/usr/share/kickstarts/$DEVICE.ks"

mkdir -p "$CI_PROJECT_DIR/images"

"$PLATFORM_SDK_ENTER" bash -lc "
  set -euo pipefail
  mic create fs $KICKSTART \
    -o /tmp/mic-out \
    -A $PORT_ARCH \
    --tokenmap=ARCH:$PORT_ARCH,RELEASE:$SFOS_VERSION
"

cp /tmp/mic-out/*.zip "$CI_PROJECT_DIR/images/" 2>/dev/null || \
  cp -r /tmp/mic-out "$CI_PROJECT_DIR/images/"
