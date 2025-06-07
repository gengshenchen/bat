#!/bin/bash

echo "--- USB设备诊断报告 ---"
echo "本报告将列出所有USB设备的关键属性，以帮助诊断问题。"
echo

for dev_path in /sys/bus/usb/devices/*; do
    if [ -d "$dev_path" ]; then
        echo "========================================"
        echo "检测设备路径: ${dev_path}"

        # 打印基本信息
        if [ -f "${dev_path}/idVendor" ]; then
            VENDOR=$(cat "${dev_path}/idVendor")
            PRODUCT=$(cat "${dev_path}/idProduct")
            NAME=$(cat "${dev_path}/product" 2>/dev/null || echo "N/A")
            echo "  -> ID: ${VENDOR}:${PRODUCT} - ${NAME}"
        fi

        # --- 以下是诊断的关键 ---

        # 1. 检查 bDeviceClass
        if [ -f "${dev_path}/bDeviceClass" ]; then
            CLASS=$(cat "${dev_path}/bDeviceClass")
            echo "  -> 设备类别 (bDeviceClass): ${CLASS}"
            if [ "$CLASS" == "09" ]; then
                echo "     (诊断: 这是一个Hub设备)"
            fi
        else
            echo "  -> 设备类别 (bDeviceClass): 文件不存在"
        fi

        # 2. 检查驱动程序
        if [ -L "${dev_path}/driver" ]; then
            DRIVER_LINK=$(readlink -f "${dev_path}/driver")
            echo "  -> 驱动程序 (driver): ${DRIVER_LINK}"
            if [[ "$DRIVER_LINK" == */usb/drivers/hub ]]; then
                echo "     (诊断: 这是一个由通用'hub'驱动管理的设备)"
            fi
        else
            echo "  -> 驱动程序 (driver): 链接不存在"
        fi
        echo "========================================"
        echo
    fi
done

echo "--- 报告结束 ---"
