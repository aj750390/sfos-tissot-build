#!/bin/bash
set -euo pipefail

UBUNTU_CHROOT_SDK_PATH="/srv/sailfishos/sdks/ubuntu"

if [ ! -x "$PLATFORM_SDK_ROOT/sdk-chroot" ]; then
  echo "Platform SDK not found at $PLATFORM_SDK_ROOT/sdk-chroot"
  echo "Install it once, manually, on this runner host:"
  echo " https://docs.sailfishos.org/Tools/Platform_SDK/Installation/"
  exit 1
fi

echo "Platform SDK found. Verifying sdk-chroot works..."
if ! sudo "$PLATFORM_SDK_ROOT/sdk-chroot" -c "echo SDK_OK" 2>/dev/null; then
  echo "Warning: could not auto-verify sdk-chroot; continuing anyway"
fi

echo "Checking HABUILD Ubuntu chroot inside SDK..."
if ! sudo "$PLATFORM_SDK_ROOT/sdk-chroot" -c "test -d $UBUNTU_CHROOT_SDK_PATH" 2>/dev/null; then
  echo "HABUILD Ubuntu chroot not found inside SDK at $UBUNTU_CHROOT_SDK_PATH"
  echo "Set it up once: sdk-chroot -c 'ubu-chroot -r $UBUNTU_CHROOT_SDK_PATH init'"
  exit 1
fi

echo "HABUILD Ubuntu chroot found and accessible."
