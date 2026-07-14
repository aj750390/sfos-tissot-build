#!/bin/bash
set -e

echo "--- Starting Sync Phase for tissot (Halium 9) ---"

# 1. Clean and reset the local manifests
rm -rf .repo/local_manifests/
mkdir -p .repo/local_manifests

# 2. Write a perfectly clean roomservice manifest
cat << 'EOF' > .repo/local_manifests/roomservice.xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="muppets-gitlab" fetch="https://gitlab.com" />
  
  <project name="LineageOS/android_device_xiaomi_tissot" path="device/xiaomi/tissot" remote="github" revision="lineage-16.0" />
  <project name="LineageOS/android_device_xiaomi_msm8953-common" path="device/xiaomi/msm8953-common" remote="github" revision="lineage-16.0" />
  <project name="LineageOS/android_kernel_xiaomi_msm8953" path="kernel/xiaomi/msm8953" remote="github" revision="lineage-16.0" />
  <project name="the-muppets/proprietary_vendor_xiaomi" path="vendor/xiaomi" remote="muppets-gitlab" revision="lineage-16.0" />
</manifest>
EOF
echo "Clean local manifest successfully created."

# 3. FIX: Prevent GitLab from dropping the connection on massive repositories
git config --global http.postBuffer 524288000
git config --global http.maxRequestBuffer 100M

# 4. SMART CLEANUP: Only wipe the vendor folder if it was corrupted by the recent hangup
if [ ! -d "vendor/xiaomi/tissot" ]; then
    echo "Vendor files incomplete or corrupted. Clearing broken metadata to start fresh..."
    rm -rf vendor/xiaomi .repo/projects/vendor/xiaomi.git .repo/project-objects/the-muppets/proprietary_vendor_xiaomi.git
fi

# 5. Fire off the network sync (Throttled to -j4 to protect the connection)
echo "Starting network sync..."
repo sync -c --no-tags -j4 --force-sync

echo "--- Sync Phase Complete! ---"
