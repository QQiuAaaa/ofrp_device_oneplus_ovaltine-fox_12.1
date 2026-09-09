---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: e368a43d4a043b6962c2f622747b1c93_473d15b7ac4211f18874525400287e28
    ReservedCode1: e0cqziAyIC65jUcdw5rIEQUCoNJT4IRkzBzefz3Gkx8MoVrI3GzYRG1p35iwxcvdBlIEo4KgDRRX3ljFG8whMeMSxXTNqWL1lexy48zju7pikof4RITd3U3V7N3BxTRgdZZBCLq3Iu7tGvGIttTJwU9qkF3vwUhzyVjoqvSazXS7ZPcmeMsIRYBbd8M=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: e368a43d4a043b6962c2f622747b1c93_473d15b7ac4211f18874525400287e28
    ReservedCode2: e0cqziAyIC65jUcdw5rIEQUCoNJT4IRkzBzefz3Gkx8MoVrI3GzYRG1p35iwxcvdBlIEo4KgDRRX3ljFG8whMeMSxXTNqWL1lexy48zju7pikof4RITd3U3V7N3BxTRgdZZBCLq3Iu7tGvGIttTJwU9qkF3vwUhzyVjoqvSazXS7ZPcmeMsIRYBbd8M=
---

# OrangeFox Recovery for OVALTINE (OnePlus 9 series)

This is a custom **OrangeFox Recovery (OFRP)** device tree for the OnePlus 9 series
device whose Android 12 (ColorOS / OxygenOS / OPLUS) device codename is **ovaltine**,
targeting the **fox_12.1** OrangeFox branch (Android 12.1 era recovery).

| Feature                 | Specification                                                |
| :---------------------- | :------------------------------------------------------------|
| Device codename         | ovaltine (OPLUS, OnePlus 9 series, Android 12 / A.12 tree)   |
| Chipset                 | Qualcomm Snapdragon 888 (SM8350)                            |
| Platform codename       | ukee / lahaina                                              |
| CPU                     | Octa-core Kryo 680 (1x2.84 GHz + 3x2.42 GHz + 4x1.80 GHz)   |
| GPU                     | Adreno 660                                                   |
| Architecture            | arm64 (aarch64)                                             |
| Storage                 | UFS 3.1, dynamic logical partitions                          |
| A/B OTA                 | Yes (Virtual A/B, no dedicated system partition)            |
| Boot header             | v4 (boot + vendor_boot), LZ4 ramdisk                        |
| Decryption              | FBE (fscrypt v2 + inlinecrypt/wrappedkey, via qcom_decrypt) |

---

## About This Build

- Based on **OrangeFox Recovery 12.1** (Android 12.1 recovery base)
- Full **dynamic partition** support, **fastbootd** included
- **FBE decryption** support for Android 12 FBE data (via `qcom_decrypt` / `qcom_decrypt_fbe`)
- Uses the stock **vendor_boot / boot** kernel (no bundled prebuilt Image/dtbo —
  `TARGET_NO_KERNEL_OVERRIDE := true`, `BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true`)
- MTP, ADB sideload, backup/restore, flashing and the OrangeFox tools are functional

> Note: `ovaltine` is the OPLUS/OnePlus *internal* device codename used in the
> Android 12 (ColorOS 12 / OxygenOS 12) device tree. Physical model naming
> conventions differ across regions; keep your own device's stock boot image
> unchanged when flashing this recovery.

---

## Repository Structure

```
.
├── Android.bp               # Soong namespace (upstream TWRP/OFRP pattern)
├── Android.mk               # TARGET_DEVICE-guarded sub-makefile include
├── AndroidProducts.mk       # Lunch targets (twrp_ovaltine)
├── BoardConfig.mk           # Board-level config (boot header v4, ramdisk LZ4, ...)
├── device.mk                # Product-level config (A/B, dynamic partitions, fastbootd)
├── fox_ovaltine.mk          # OrangeFox-specific settings (GUI, tools, ...)
├── twrp_ovaltine.mk         # TWRP/OFRP product entry (generated-name template)
├── system.prop / vendor.prop
├── recovery.fstab           # Recovery mount table (OVALTINE by-name layout)
├── vendorsetup.sh           # `lunch` auto-registration (FDEVICE=ovaltine)
├── recovery/                # Recovery ramdisk overlays (init rc, twres, vendor blobs, ...)
└── .github/workflows/       # GitHub Actions: manual + monthly OFRP builds
```

---

## Compile Instructions

### Requirements

- Linux (Ubuntu 20.04+), at least ~100 GB free disk space
- `git`, `repo`, Python 3, and the OrangeFox sync tooling

### 1. Sync the OrangeFox source tree (12.1)

```bash
mkdir -p ~/OrangeFox_sync && cd ~/OrangeFox_sync
git clone https://gitlab.com/OrangeFox/sync.git
cd sync
./orangefox_sync.sh --branch 12.1 --path ~/fox_12.1
```

### 2. Clone this device tree

```bash
cd ~/fox_12.1
git clone https://github.com/AQ1601/ofrp_device_oneplus_ovaltine-fox_12.1 ./device/oneplus/ovaltine
```

### 3. Build

```bash
cd ~/fox_12.1
source build/envsetup.sh
lunch twrp_ovaltine-eng
mka recoveryimage
```

The output image lands at:
```
out/target/product/ovaltine/OrangeFox*.img
```

### Alternative: GitHub Actions

This repository ships ready-to-use workflows (`.github/workflows/`) that perform the
whole sync + build + release on GitHub's runners:

- `ovaltine_OFRP_Builder.yml` — manual workflow (dispatch), selectable manifest branch
- `AutoBuild.yml` — monthly automated build

---

## Credits

- TeamWin, the OrangeFox project, and all contributors of the involved repositories
- @AQ1601 for the original ovaltine OFRP device tree
- Upstream TWRP device trees (e.g. `android_device_OPPO_OP4ED5-twrp`) served as the
  structural reference for the completion pass

## Disclaimer

- Software is provided **as-is**, without any warranty. Use at your own risk.
- Flashing a custom recovery can void your warranty and, in rare cases, brick the
  device. Always back up important data and unlock the bootloader first.
*（内容由AI生成，仅供参考）*
