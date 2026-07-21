# sfos-tissot-build

CI scaffold for porting Sailfish OS to the Xiaomi Mi A1 (tissot), driven by
a self-hosted GitLab Runner. This repo does **not** contain the Android
source tree itself (tens of GB) — it holds the local manifest and the glue
scripts that drive `repo`, the HABUILD SDK, and the Sailfish Platform SDK.

## Pipeline stages
1. **sync** — `repo init/sync` against Halium's `halium-9.0` manifest, with
   `local_manifests/tissot.xml` pointing at tissot's Android 9 device tree,
   msm8953-common tree, kernel, and vendor blobs.
2. **hybris-hal** — builds `hybris-boot.img` / `hybris-recovery.img` inside
   the HABUILD chroot.
3. **rootfs** — builds `droid-hal-*` / `droid-config-*` RPMs inside the
   Platform SDK using `hadk-tools`.
4. **package** — runs `mic` to produce the final flashable image.

## One-time manual setup on the runner host (NOT automated by this repo)
These steps are long-running, human-in-the-loop, and only need to happen
once per runner host — CI just reuses the results:

1. Provision the runner: Ubuntu 20.04/22.04 host, 16+ cores, 32GB+ RAM,
   250GB+ free disk, `sfos-hadk` runner tag registered to this project.
2. Set up the HABUILD SDK per
   https://hadk.sailfishos.org/HowTo/HABUILD_Environment/ at
   `/srv/hadk/habuild-sdk`, then `touch /srv/hadk/habuild-sdk/.habuild-ready`.
3. Set up the Sailfish Platform SDK + sb2 targets per
   https://hadk.sailfishos.org/HowTo/Platform_SDK/ at
   `/srv/hadk/platform-sdk`.
4. Clone `hadk-tools` (e.g. https://gitlab.com/Thaodan/hadk_tools) inside
   the Platform SDK chroot's home dir.
5. Clone/create `droid-config-tissot` and `droid-hal-version-tissot` repos
   (these hold your device-specific Sailfish config, not Android sources)
   inside the Platform SDK chroot's home dir alongside hadk-tools.

## Before you trust this scaffold
- **Verify branch names in `local_manifests/tissot.xml`.** Tissot device
  trees have moved between forks (Flex1911, Linux-On-Sdm6Series, etc.) over
  the years; confirm the branches referenced still exist and still build.
- I have not run this pipeline end-to-end — treat every script here as a
  first draft to debug against your actual runner, not a known-working
  build. Expect to iterate, especially on `build-droid-hal.sh` and
  `build-image.sh`, whose exact commands depend on your `hadk-tools`
  version and kickstart file layout.
- Ask in `#sailfishos-porters` on OFTC if you get stuck on a specific
  build error — that's where most tissot/msm8953 porting knowledge lives.

## Layout
```
.gitlab-ci.yml
local_manifests/tissot.xml
scripts/
  setup-habuild.sh
  sync-source.sh
  build-hybris-hal.sh
  build-droid-hal.sh
  build-image.sh
```
