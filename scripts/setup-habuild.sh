#!/bin/bash
set -euo pipefail

# Platform SDK + the HABUILD Ubuntu chroot are installed ONCE, by hand, on
# the runner host, per:
#   Platform SDK: https://docs.sailfishos.org/Tools/Platform_SDK/Installation/
#   HABUILD chroot: https://hadk.sailfishos.org/setupsdk/
#
# This script only verifies they're already present at $PLATFORM_SDK_ROOT
# and fails fast with instructions if not - it does not attempt to
# install multi-GB SDKs inside a CI job.

UBUNTU_CHROOT="$PLATFORM_SDK_ROOT/sdks/ubuntu"

if [ ! -x "$PLATFORM_SDK_ROOT/sdk-chroot" ]; then
  echo "Platform SDK not found at $PLATFORM_SDK_ROOT."
  echo "Install it once, manually, on this runner host:"
  echo "  https://docs.sailfishos.org/Tools/Platform_SDK/Installation/"
  exit 1
fi

if [ ! -d "$UBUNTU_CHROOT" ]; then
  echo "HABUILD Ubuntu chroot not found at $UBUNTU_CHROOT."
  echo "Set it up once, manually, following:"
  echo "  https://hadk.sailfishos.org/setupsdk/"
  exit 1
fi

echo "Platform SDK and HABUILD chroot found. Verifying ubu-chroot works..."
"$PLATFORM_SDK_ROOT/sdk-chroot" -c "ubu-chroot -r $UBUNTU_CHROOT echo HABUILD_SDK_OK" 2>/dev/null \
  || echo "Warning: could not auto-verify ubu-chroot; continuing anyway - build-hybris-hal.sh will fail loudly if it's actually broken."
