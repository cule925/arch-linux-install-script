#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/system/check_system_info.sh'"

echo -e "\n========================SYSTEM SPECS=======================\n"

# Check if system is UEFI or BIOS
if [[ -d /sys/firmware/efi ]]; then
	echo "SYSTEM_TYPE=UEFI" | tee /tmp/archlinux-install-script-files/important_specs.txt
else
	echo "SYSTEM_TYPE=BIOS" | tee /tmp/archlinux-install-script-files/important_specs.txt
fi

# Check CPU vendor
CPU_VENDOR=$(lscpu | grep "^Vendor ID" | awk '{print $3}')
echo "CPU_VENDOR=$CPU_VENDOR" | tee -a /tmp/archlinux-install-script-files/important_specs.txt

# Check CPU architecture
ARCH=$(uname -m)
echo "ARCH=$ARCH" | tee -a /tmp/archlinux-install-script-files/important_specs.txt

# Check GPU manufacturer
GPU_INFO=$(lspci | grep -E "VGA|3D")

if echo "$GPU_INFO" | grep -qi "AMD"; then
	echo "GPU_VENDOR=AMD" | tee -a /tmp/archlinux-install-script-files/important_specs.txt
elif echo "$GPU_INFO" | grep -qi "NVIDIA"; then
	echo "GPU_VENDOR=NVIDIA" | tee -a /tmp/archlinux-install-script-files/important_specs.txt	
else
	echo "GPU_VENDOR=OTHER" | tee -a /tmp/archlinux-install-script-files/important_specs.txt
fi

echo ""

# Check if system meets the limitations of the install script
if [[ "$ARCH" != "x86_64" ]]; then
	echo "Unsupported architecture: $ARCH, exiting ..."
	exit 1
fi

debug "SCRIPT '{PROJECT_ROOT}/system/check_system_info.sh' FINISHED EXECUTING (CODE: 0)"
exit 0
