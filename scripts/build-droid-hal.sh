#!/bin/bash
set -euo pipefail

# Runs inside the Platform SDK (sb2 targets), per HADK "Building the
# packages". hadk-tools, droid-config-$DEVICE, and droid-hal-version-$DEVICE
# are expected to already exist in the Platform SDK chroot's home dir -
# that's a one-time manual setup, not something this script creates.

mkdir -p "$GITHUB_WORKSPACE/artifacts/rpms"

"$PLATFORM_SDK_ROOT/sdk-chroot" -c "
  set -euo pipefail
  export ANDROID_ROOT='$ANDROID_ROOT'
  export VENDOR='$VENDOR'
  export DEVICE='$DEVICE'
  export PORT_ARCH='$PORT_ARCH'
  cd ~/hadk-tools
  ./prepare.sh \$DEVICE
  ./build_packages.sh -d
"

# hadk-tools/build_packages.sh drops RPMs under $ANDROID_ROOT/droid-local-repo/
# by convention; adjust this glob if your hadk-tools version differs.
find "$ANDROID_ROOT/droid-local-repo/$DEVICE" -name '*.rpm' \
  -exec cp {} "$GITHUB_WORKSPACE/artifacts/rpms/" \;
