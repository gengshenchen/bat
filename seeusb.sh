#!/bin/bash

echo "正在扫描系统中的所有外部 USB Hub..."
echo "========================================="

found_hub=false

# 遍历所有USB设备
for hub_path in /sys/bus/usb/devices/*; do
    # 检查bDeviceClass文件是否存在
    if [ ! -f "${hub_path}/bDeviceClass" ]; then
        continue
    fi

    # 检查设备类别是否为 09 (Hub)
    if [ "$(cat "${hub_path}/bDeviceClass")" == "09" ]; then
        
        # 通过设备路径名是否包含'-'来判断是否为外部Hub
        if [[ "$(basename "$hub_path")" == *-* ]]; then
            
            found_hub=true
            HUB_VENDOR=$(cat "${hub_path}/idVendor")
            HUB_PRODUCT=$(cat "${hub_path}/idProduct")
            HUB_NAME=$(cat "${hub_path}/product" 2>/dev/null || echo "Unknown Hub")
            HUB_KERNEL_NAME=$(basename "$hub_path")

            echo
            echo "发现外部 Hub: ${HUB_NAME} (ID: ${HUB_VENDOR}:${HUB_PRODUCT})"
            echo "  - Hub 路径: ${hub_path}"
            echo "  - 连接的设备列表:"

            found_devices_on_hub=false
            # 查找并分析连接到此Hub上的设备 (例如 /sys/bus/usb/devices/2-1/*)
            for device_path in ${hub_path}/${HUB_KERNEL_NAME}:*/*; do
                if [ -d "$device_path" ] && [ -f "${device_path}/idVendor" ]; then
                    found_devices_on_hub=true
                    # 从路径中提取端口号
                    PORT=$(basename "$device_path" | cut -d'.' -f2 | cut -d':' -f1)
                    
                    SPEED=$(cat "${device_path}/speed" 2>/dev/null || echo 'unknown')
                    SPEED_TEXT="Unknown Speed"
                    case "$SPEED" in
                        5000)   SPEED_TEXT="USB 3.0 (SuperSpeed)";;
                        10000)  SPEED_TEXT="USB 3.1/3.2 (SuperSpeed+)";;
                        480)    SPEED_TEXT="USB 2.0 (HighSpeed)";;
                        12)     SPEED_TEXT="USB 1.1 (FullSpeed)";;
                    esac

                    DEVICE_NAME=$(cat "${device_path}/product" 2>/dev/null || echo "Unknown Device")
                    DEVICE_VENDOR=$(cat "${device_path}/idVendor" 2>/dev/null)
                    DEVICE_PRODUCT=$(cat "${device_path}/idProduct" 2>/dev/null)

                    echo "    * 端口 ${PORT}:"
                    echo "      - 设备: ${DEVICE_NAME} (ID: ${DEVICE_VENDOR}:${DEVICE_PRODUCT})"
                    echo "      - 速度: ${SPEED_TEXT}"
                fi
            done

            if [ "$found_devices_on_hub" = false ]; then
                echo "    (此Hub上当前没有连接任何设备)"
            fi
        fi
    fi
done

echo "========================================="
if [ "$found_hub" = false ]; then
    echo
    echo "未在系统中检测到任何外部 USB Hub。"
fi
echo "扫描完成。"
