#!/bin/bash
set -euo pipefail

# Runs the Android-side build steps inside the HABUILD SDK chroot, per
# HADK chapter "Building the Hybris HAL". Assumes setup-habuild.sh and
# sync-source.sh already ran.

HABUILD_ENTER="$HABUILD_SDK/habuild_sdk_run.sh"   # wrapper around chroot/schroot for HABUILD

if [ ! -x "$HABUILD_ENTER" ]; then
  echo "HABUILD entry wrapper not found/executable at $HABUILD_ENTER"
  exit 1
fi

"$HABUILD_ENTER" bash -lc "
  set -euo pipefail
  source $ANDROID_ROOT/build/envsetup.sh
  breakfast $DEVICE
  cd $ANDROID_ROOT
  make -j\$(nproc) hybris-hal
"

# Sanity check that the artifacts CI expects actually exist before we
# report success.
OUT_DIR="$ANDROID_ROOT/out/target/product/$DEVICE"
test -f "$OUT_DIR/hybris-boot.img"
test -f "$OUT_DIR/hybris-recovery.img"
echo "hybris-boot.img and hybris-recovery.img built OK."
