#!/bin/bash
set -euo pipefail

if [ ! -x "$PLATFORM_SDK_ROOT/sdk-chroot" ]; then
  echo "Platform SDK not found at $PLATFORM_SDK_ROOT/sdk-chroot"
  echo "Install it once, manually, on this runner host:"
  echo " https://docs.sailfishos.org/Tools/Platform_SDK/Installation/"
  exit 1
fi

echo "Platform SDK found at $PLATFORM_SDK_ROOT."

# Verify sdk-chroot works by running a simple command
if ! echo "SDK_OK" | sudo "$PLATFORM_SDK_ROOT/sdk-chroot" cat 2>/dev/null; then
  echo "Warning: could not auto-verify sdk-chroot; continuing anyway"
fi

# Check ubuntu chroot on the host filesystem (direct path)
UBUNTU_CHROOT_HOST_PATH="$PLATFORM_SDK_ROOT/srv/sailfishos/sdks/ubuntu"
if [ ! -d "$UBUNTU_CHROOT_HOST_PATH/etc" ]; then
  echo "HABUILD Ubuntu chroot not found at $UBUNTU_CHROOT_HOST_PATH"
  echo "Set it up once, on the host:"
  echo "  sudo $PLATFORM_SDK_ROOT/sdk-chroot ubu-chroot -r $UBUNTU_CHROOT_HOST_PATH init"
  exit 1
fi

echo "HABUILD Ubuntu chroot found and accessible."
