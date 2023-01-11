$(call inherit-product, vendor/arrow/config/common.mk)
$(call inherit-product, vendor/arrow/config/BoardConfigSoong.mk)
$(call inherit-product, device/arrow/sepolicy/common/sepolicy.mk)
-include vendor/arrow/build/core/config.mk

TARGET_BOOT_ANIMATION_RES := 1080

TARGET_USES_PREBUILT_VENDOR_SEPOLICY := true
TARGET_HAS_FUSEBLK_SEPOLICY_ON_VENDOR := true

DISABLE_LE_READ_BUFFER_SIZE_V2 := true

PRODUCT_PACKAGES += \
    libaptX_encoder \
    libaptXHD_encoder

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.system.ota.json_url=https://raw.githubusercontent.com/ponces/treble_build_arrow/arrow-13.0/ota.json
