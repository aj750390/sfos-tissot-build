#!/bin/bash
set -euo pipefail

KICKSTART_REL="droid-config-$DEVICE/sparse/usr/share/kickstarts/$DEVICE.ks"
MIC_OUT="/tmp/mic-out-$DEVICE"

mkdir -p "$GITHUB_WORKSPACE/artifacts/images"

"$PLATFORM_SDK_ROOT/sdk-chroot" -c "
  set -euo pipefail
  rm -rf '$MIC_OUT'
  cd ~
  mic create fs '$KICKSTART_REL' \
    -o '$MIC_OUT' \
    -A '$PORT_ARCH' \
    --tokenmap=ARCH:'$PORT_ARCH',RELEASE:'$SFOS_VERSION'
"

cp -r "$MIC_OUT"/* "$GITHUB_WORKSPACE/artifacts/images/"
