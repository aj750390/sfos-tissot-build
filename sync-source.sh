#!/bin/bash
set -euo pipefail

# Cache the .repo object store on the runner host between pipeline runs -
# a full halium-9.0 sync is tens of GB and you do not want to re-download
# it on every commit. This mounts/copies a persistent cache dir.
REPO_CACHE="/srv/hadk/repo-cache"
mkdir -p "$REPO_CACHE"

mkdir -p "$ANDROID_ROOT"
cd "$ANDROID_ROOT"

if [ ! -d .repo ]; then
  repo init -u https://github.com/Halium/android -b halium-9.0 --depth=1
fi

mkdir -p .repo/local_manifests
cp "$CI_PROJECT_DIR/local_manifests/tissot.xml" .repo/local_manifests/tissot.xml

repo sync -c -j"$(nproc)" --force-sync --no-clone-bundle --optimized-fetch \
  --repo-cache-dir="$REPO_CACHE"
