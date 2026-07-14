#!/bin/bash
set -e

echo "--- Starting Build Phase for tissot ---"

# Set Android build variables
export USER=builder
export LC_ALL=C
export ALLOW_MISSING_DEPENDENCIES=true

# Fallback symlink to ensure python commands resolve correctly inside the container
sudo ln -sf $(which python3 || which python2) /usr/local/bin/python || true

# Initialize the Android build environment
source build/envsetup.sh
lunch lineage_tissot-userdebug

# Dummy folder to prevent the Metalava documentation crash
mkdir -p tools/metalava/manual

# Delete the old Ninja blueprint so it sees all the newly downloaded C++ files
rm -f out/build-*.ninja

# Compile the Hardware Abstraction Layer
make -j$(nproc) hybris-hal

echo "--- Build Complete! ---"
