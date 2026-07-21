#!/bin/bash
set -euo pipefail

# HABUILD SDK is a big (~few GB) Ubuntu chroot used to build the Android/
# hybris side of the port. This is expensive to set up, so we do it once
# per runner host and reuse it across pipeline runs instead of rebuilding
# it in every job.
#
# Expected layout on the runner host (outside the git checkout, persistent
# across jobs): /srv/hadk/habuild-sdk

HABUILD_HOST_PATH="/srv/hadk/habuild-sdk"

if [ -d "$HABUILD_HOST_PATH/.habuild-ready" ]; then
  echo "HABUILD SDK already provisioned at $HABUILD_HOST_PATH, linking into workspace."
else
  echo "HABUILD SDK not found at $HABUILD_HOST_PATH."
  echo "Provision it once, manually, on the runner host following:"
  echo "  https://hadk.sailfishos.org/HowTo/HABUILD_Environment/"
  echo "Then touch $HABUILD_HOST_PATH/.habuild-ready and re-run this pipeline."
  exit 1
fi

ln -sfn "$HABUILD_HOST_PATH" "$HABUILD_SDK"
