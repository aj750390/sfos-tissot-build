#!/bin/bash
set -euo pipefail

# Runs inside the Sailfish Platform SDK chroot (sb2 targets), per HADK
# chapter "Building the packages". Assumes hadk-tools is checked out at
# $PLATFORM_SDK_ROOT/hadk-tools and droid-config-$DEVICE / droid-hal-version-$DEVICE
# repos are checked out alongside this project (add them as git submodules
# or separate CI dependency jobs if they live in their own repos).

PLATFORM_SDK_ENTER="/srv/hadk/platform-sdk/sdk-chroot"

if [ ! -x "$PLATFORM_SDK_ENTER" ]; then
  echo "Platform SDK entry script not found/executable at $PLATFORM_SDK_ENTER"
  exit 1
fi

mkdir -p "$CI_PROJECT_DIR/rpms"

"$PLATFORM_SDK_ENTER" bash -lc "
  set -euo pipefail
  export VENDOR=$VENDOR DEVICE=$DEVICE PORT_ARCH=$PORT_ARCH
  export ANDROID_ROOT=$ANDROID_ROOT

  # Regenerate droid-hal-version spec, then build the droid-hal-* and
  # droid-config-* packages for the sb2 target.
  cd ~/hadk-tools
  ./prepare.sh \$DEVICE
  ./build_packages.sh -d
"

find ~ -name '*.rpm' -newer /tmp -exec cp {} "$CI_PROJECT_DIR/rpms/" \; || true
