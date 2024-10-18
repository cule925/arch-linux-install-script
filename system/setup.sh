#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/system/setup.sh'"

# Čita /tmp/archlinux-install-script-files/important_specs.txt
source /tmp/archlinux-install-script-files/important_specs.txt

# Osvježavanje ključeva za potpisivanje
echo ""
read -p "Do you want to refresh package manager keys? [y/n (default)]: " INPUT_1

# Provjeri je li ulaz y ili Y
if [[ "$INPUT_1" == "y" || "$INPUT_1" == "Y" ]]; then
	pacman-key --refresh-key
fi

# Instalacija
echo -e "\n***********************************************************\n"

# Jezgra i osnovni paketi za korištenje sustava
KERNEL_AND_BASE_PACKAGES=$(cat ./system/kernel_and_base_packages.txt)

# GRUB bootloader paketi
if [[ "$SYSTEM_TYPE" == "UEFI" ]]; then
	BOOTLOADER_PACKAGES=$(cat ./bootloader/bootloader_packages_uefi.txt)
else
	BOOTLOADER_PACKAGES=$(cat ./bootloader/bootloader_packages_bios.txt)
fi

# Mikrokod
if [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
	echo "Detected AMD CPU ..."
	MICROCODE_PACKAGES="amd-ucode"
elif [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
	echo "Detected Intel CPU ..."
	MICROCODE_PACKAGES="intel-ucode"
else
	echo "No AMD or Intel CPU detected ..."
	MICROCODE_PACKAGES=""
fi

read -p "Are you running in this in a VM? [y (default)/n]: " VM

# Paketi za korisnika
if [[ "$VM" != "n" || "$VM" != "N" ]]; then
	echo "Not installing microcode then ..."
	MICROCODE_PACKAGES=""
fi

# Grafika
if [[ "$GPU_VENDOR" == "AMD" ]]; then
	echo "Detected AMD graphics ..."
	GRAPHICS_PACKAGES="mesa"
elif [[ "$GPU_VENDOR" == "NVDIA" ]]; then
	echo "Detected NVIDIA graphics ..."
	GRAPHICS_PACKAGES="nvidia-open"
else
	echo "No AMD or NVIDIA GPU detected ..."
	GRAPHICS_PACKAGES=""
fi

# Uobičajeni paketi (uređivač teksta, razni mrežni paketi)
DEFAULT_PACKAGES=$(cat ./system/default_packages.txt)

read -p "Minimalist install? [y (default)/n]: " INPUT_2

# Paketi za korisnika
if [[ "$INPUT_2" == "n" || "$INPUT_2" == "N" ]]; then
	echo "You chose non-minimalist installation, custom package list will be read!"
	cat ./custom_packages.txt | tee /tmp/archlinux-install-script-files/custom_packages.txt > /dev/null
	cat ./custom_gui_packages.txt | tee /tmp/archlinux-install-script-files/custom_gui_packages.txt > /dev/null
else
	echo "You chose minimalist installation!"
fi

# Odabir desktop okruženja
./desktop-environment/choose_environment.sh

# Instalacija paketa
pacstrap -K /mnt $KERNEL_AND_BASE_PACKAGES $BOOTLOADER_PACKAGES $MICROCODE_PACKAGES $GRAPHICS_PACKAGES $DEFAULT_PACKAGES \
$(cat /tmp/archlinux-install-script-files/custom_packages.txt) \
$(cat /tmp/archlinux-install-script-files/custom_gui_packages.txt) \
$(cat /tmp/archlinux-install-script-files/desktop_environment_packages.txt)

# Generiranje fstab datoteke
genfstab -U /mnt | tee /mnt/etc/fstab

# Početne postavke
check_script_retval "./system/arch_chroot_initial_setup.sh"

# Konfiguracija GRUB bootloadera
check_script_retval "./bootloader/bootloader_setup.sh"

# Konfiguracija desktop okruženja
./desktop-environment/enable_environment.sh

# Čita ulaz
read -p "Do you want to execute your custom arch-root script? [y/n]: " INPUT_3

# Provjeri je li ulaz y, Y, ili tipka Enter
if [[ "$INPUT_3" == "y" || "$INPUT_3" == "Y" || "$INPUT_3" == "" ]]; then
	./arch_chroot_custom.sh
fi

echo -e "\n***********************************************************\n"

debug "SCRIPT '{PROJECT_ROOT}/system/setup.sh' FINISHED EXECUTING (CODE: 0)"
exit 0
