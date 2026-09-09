---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: e368a43d4a043b6962c2f622747b1c93_46270deeac4211f18f50525400aeaaa3
    ReservedCode1: YuPlva2uoITMLmK3MCvd8aBAIbGv+4V4DxpFtpHZzgLeMhnO9qATE/tLQfYZEVdr5mdFTINifvDgNWuPkCg2jJELu6EhVWvCXm2U6gMWLPsPy3WztOLxFl0LrvVS8hF1f6wYNvuGcRfUa96H6pffkNie2m4OtQorOYKLZJjA9pbt+onhbR9KNOaYQgw=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: e368a43d4a043b6962c2f622747b1c93_46270deeac4211f18f50525400aeaaa3
    ReservedCode2: YuPlva2uoITMLmK3MCvd8aBAIbGv+4V4DxpFtpHZzgLeMhnO9qATE/tLQfYZEVdr5mdFTINifvDgNWuPkCg2jJELu6EhVWvCXm2U6gMWLPsPy3WztOLxFl0LrvVS8hF1f6wYNvuGcRfUa96H6pffkNie2m4OtQorOYKLZJjA9pbt+onhbR9KNOaYQgw=
---

# 修复前后差异说明清单 (COMPARISON.md)

> 对比对象：
> - 仓库 A = `AQ1601/ofrp_device_oneplus_ovaltine-fox_12.1`（OrangeFox / OFRP，OnePlus ovaltine，Android 12.1，fox_12.1 分支）
> - 仓库 B = `rtyutechstudio/android_device_OPPO_OP4ED5-twrp`（TWRP，OPPO OP4ED5 / OPPO Reno6 5G，MTK，main 分支）
>
> 修复原则：以仓库 B 的**成熟结构/惯例**为参照，对仓库 A 做补全与纠错，同时
> **保持 OnePlus ovaltine 自身正确信息（SM8350/ukee、A/B、boot header v4、vendor_boot、
> qcom 私库与固件等）不被 B 的 MTK 配置覆盖**。

---

## 1. 两仓库基础概览

| 项目 | 仓库 A（被完善对象） | 仓库 B（参照对象） |
| :--- | :------------------ | :----------------- |
| Recovery | OrangeFox (OFRP) fox_12.1 | TWRP |
| 设备 | OnePlus ovaltine（9 系列，A.12 代号） | OPPO OP4ED5（Reno6 5G，Garen） |
| SoC | Qualcomm SM8350（平台 ukee / lahaina） | MediaTek MT6877（Dimensity 900） |
| 分区形态 | A/B + Virtual A/B + dynamic partitions | MTK dynamic partitions（非 A/B） |
| Boot | boot + vendor_boot（header v4，LZ4） | 传统 boot + prebuilt dtb/dtbo |
| 内核 | `TARGET_NO_KERNEL_OVERRIDE := true`（不内置 prebuilt 内核） | `TARGET_PREBUILT_KERNEL := prebuilt/Image` |
| 目录清单 | .github, AndroidProducts.mk, BoardConfig.mk, device.mk, fox_ovaltine.mk, twrp_ovaltine.mk, recovery.fstab, recovery/, system.prop, vendor.prop, vendorsetup.sh, README.md | .gitattributes, Android.bp, Android.mk, AndroidProducts.mk, BoardConfig.mk, device.mk, prebuilt/, recovery/root/, security/, system.prop, twrp_OP4ED5.mk, README.md |

> 关键判断：两设备平台差异巨大（QCOM vs MTK），**B 的 prebuilt 内核/dtb、MTK fstab、
> MTK props 等硬件相关配置不能照搬**。可借鉴的是 B 的**工程结构**（Android.bp /
> Android.mk / .gitattributes / 详细 README）与**成熟配置惯例**（BY-name 分区一致性、
> 背光/屏幕声明、TARGET_DEVICE 守卫等）。

---

## 2. 仓库 A 的缺失项 → 本次已补全

| 缺失项 | 说明 | 修复方式 |
| :----- | :--- | :------- |
| `Android.bp` | 无 Soong namespace 声明，与 B 的结构标杆不一致 | 新增，定义 `soong_namespace {}` |
| `Android.mk` | 无顶层 makefile 入口、无 TARGET_DEVICE 守卫 | 新增，采用 B 的 `all-subdir-makefiles` + 设备守卫模式（修正为 ifneq 语义） |
| `.gitattributes` | 无文本 LF / 二进制保护规则 | 新增，参照 B 的规则（mk/bp/rc/fstab/prop 强制 LF；ko/so/bin/img/dtb/kernel/image 按二进制处理） |
| `README.md` | 仅一行标题，无可读性与构建说明 | 重写：补充设备规格、仓库结构、`orangefox_sync.sh --branch 12.1` + `lunch twrp_ovaltine-eng` + `mka recoveryimage` 构建流程、GHA 说明与免责声明 |
| `TW_BRIGHTNESS_PATH` | 背光 sysfs 路径未显式声明（B 类成熟树均显式给出） | BoardConfig.mk 补充为 `/sys/class/backlight/panel0-backlight/brightness`（与仓库自带 `init.recovery.qcom.rc` 写入路径一致，已验证） |
| 屏幕分辨率声明 | 缺 TARGET_SCREEN_WIDTH/HEIGHT/DENSITY | 补充 1080x2400 / 420（与 OF_SCREEN_H=2400 一致） |

---

## 3. 仓库 A 的错误配置 → 本次已修正

| 错误项 | 位置 | 问题 | 修复 |
| :----- | :--- | :--- | :--- |
| 设备代号错误 | `vendorsetup.sh` `FDEVICE="diting"` | 拷贝遗留：错误指向其他设备（diting），导致 `add_lunch_combo` / OF 构建取错设备名 | 改为 `FDEVICE="ovaltine"` |
| 备用设备名错误 | `vendorsetup.sh` `TARGET_DEVICE_ALT="diting"` | 同源拷贝遗留，会污染设备别名匹配 | 删除该行 |
| 分区路径不一致 | `recovery.fstab` `/dev/block/by-name/metadata` | 与同文件 userdata 等使用 `/dev/block/bootdevice/by-name/...` 前缀不一致（OnePlus 9 为 bootdevice 布局） | 统一为 `/dev/block/bootdevice/by-name/metadata` |

---

## 4. 仓库 A 的重复 / 冗余声明 → 本次已清理

| 冗余项 | 位置 | 问题 | 修复 |
| :----- | :--- | :--- | :--- |
| `FOX_MOVE_MAGISK_INSTALLER_TO_RAMDISK=1` | `vendorsetup.sh` | 同一变量重复 export 两处 | 删除重复的第二处 |
| `BUILD_BROKEN_DUP_RULES := true` | `device.mk` 与 `BoardConfig.mk` | Board 级变量在 product 文件里重复设置 | 保留 BoardConfig.mk 一处，删除 device.mk 中重复行 |

---

## 5. 刻意保留、未被修改的 OnePlus ovaltine 自身信息（防误覆盖）

| 配置 | 值 | 为什么保留 |
| :--- | :-- | :--------- |
| 平台/厂商 | ukee / qualcomm / OnePlus，`PRODUCT_PLATFORM := ukee` | ovaltine 的 QCOM 平台，未因参照 MTK 树而改动 |
| 内核来源 | `TARGET_NO_KERNEL_OVERRIDE := true`、`BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true`、无 prebuilt | 使用设备自带 vendor_boot/boot 内核；B 的 prebuilt/Image 属 MTK 场景，刻意不引入 |
| Boot 头 | `BOARD_BOOT_HEADER_VERSION := 4` + vendor_boot + LZ4 | OnePlus 9 的 A/B Android 12 形态 |
| A/B 与全量更新 | A/B updater、update_engine 1.2-impl-qti、AB_OTA_PARTITIONS、口碑分区清单 | 设备自身 A/B 架构 |
| 加密 | qcom_decrypt / qcom_decrypt_fbe、fscrypt v2 / inlinecrypt / wrappedkey | ovaltine 的 Android 12 FBE 方案 |
| 私库/固件 | `recovery/root/` 下 qcom vendor libs、firmware、init.recovery.qcom.usb rc、twres | recovery 映像运行所需，整体保留 |
| 分区表 | dynamic partitions + OPLUS my_* 逻辑分区 + fastbootd | 设备原厂分区布局 |
| 自带 GHA | `.github/workflows/*.yml`（手动 + 月度构建） | 直接支撑 OFRP 构建，保留 |

---

## 6. 修复前后一致性核对

- [x] 全库扫描未发现其余遗留设备名（diti/neptune/lemonade/kebab 等均无残留，唯一 `diting` 已修正）
- [x] 新增文件不引用任何 B 的 MTK 专属内容（无 mt6877 / beanpod / MTK fstab / prebuilt）
- [x] 顶层关键 makefile（AndroidProducts.mk / twrp_ovaltine.mk / fox_ovaltine.mk / device.mk / BoardConfig.mk）的继承链与 lunch 目标 `twrp_ovaltine-eng` 保持一致
- [x] `recovery.fstab`（根目录）与 `recovery/root/system/etc/twrp.flags` 的分区前缀一致（bootdevice）

---

## 7. 交付说明

完善后的完整仓库已生成到桌面：
```
%USERPROFILE%\Desktop\ofrp_device_oneplus_ovaltine-fox_12.1_completed
```
（不含 .git 目录，含全部版本文件、recovery/root 与新增/修复项；如需携带 git 历史请从原始仓库另行 clone）
*（内容由AI生成，仅供参考）*
