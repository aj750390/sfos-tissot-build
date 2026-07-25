#!/bin/bash
set -euo pipefail

if [ ! -d "$ANDROID_ROOT/.repo" ]; then
  cat <<EOF
ERROR: Source tree not found at $ANDROID_ROOT/.repo

The Android source tree must be set up manually ONCE on the runner host.
To do so, run:

  repo init -u https://github.com/Halium/android -b halium-9.0 --depth=1

inside $ANDROID_ROOT, then re-run this workflow.
EOF
  exit 1
fi

echo "Existing .repo found at $ANDROID_ROOT - attempting incremental sync..."

# Copy local manifest if present (optional)
if [ -f "$GITHUB_WORKSPACE/local_manifests/tissot.xml" ]; then
  sudo mkdir -p "$ANDROID_ROOT/.repo/local_manifests"
  sudo chown -R "$(whoami)" "$ANDROID_ROOT/.repo/local_manifests" 2>/dev/null || true
  cp "$GITHUB_WORKSPACE/local_manifests/tissot.xml" "$ANDROID_ROOT/.repo/local_manifests/tissot.xml"
  echo "Copied local manifest."
else
  echo "No local_manifests/tissot.xml found in workspace – skipping."
fi

cd "$ANDROID_ROOT"

# Disable git terminal prompts so repo sync won't hang
export GIT_TERMINAL_PROMPT=0

# Try to sync, but do not fail the job if it fails
if repo sync -c -j"$(nproc)" --force-sync --no-clone-bundle --optimized-fetch; then
  echo "Sync succeeded."
else
  echo "WARNING: repo sync had errors (likely network/auth), but continuing with existing source."
  echo "If you need a full fresh source, run repo sync manually outside of CI."
fi

echo "Current manifest reference:"
head -5 .repo/manifest.xml 2>/dev/null || echo "manifest.xml not found"
