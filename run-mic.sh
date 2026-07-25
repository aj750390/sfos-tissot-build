#!/bin/bash
set -euo pipefail

source tissot.env

echo "=== Build script started ==="
echo "Device: $DEVICE"
echo "Android root: $ANDROID_ROOT"

if [ -d "$ANDROID_ROOT" ]; then
    echo "Android source found."
else
    echo "Android source not mounted – skipping HAL build"
fi

echo "Checking mic..."
mic --version

echo "=== Build script finished ==="
