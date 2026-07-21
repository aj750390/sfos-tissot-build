#!/bin/bash
set -euo pipefail

# ANDROID_ROOT ($/srv/hadk/hadk) is a FIXED, PERSISTENT path on the runner
# host - not under github.workspace. First run does a full repo
# init+sync (~tens of GB, expect it to take a long time); every run after
# that is incremental, since .repo/ already exists and is reused.

sudo mkdir -p "$ANDROID_ROOT"
sudo chown -R "$(whoami)" "$ANDROID_ROOT"
cd "$ANDROID_ROOT"

if [ ! -d .repo ]; then
  echo "No existing .repo found at $ANDROID_ROOT - doing first-time repo init."
  repo init -u https://github.com/Halium/android -b halium-9.0 --depth=1
else
  echo "Existing .repo found at $ANDROID_ROOT - reusing it, syncing incrementally."
fi

mkdir -p .repo/local_manifests
cp "$GITHUB_WORKSPACE/local_manifests/tissot.xml" .repo/local_manifests/tissot.xml

repo sync -c -j"$(nproc)" --force-sync --no-clone-bundle --optimized-fetch
