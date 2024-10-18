#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/system-setup/setup.sh'"

# Čita /tmp/archlinux-install-script-files/important_specs.txt
source /tmp/archlinux-install-script-files/important_specs.txt

# Osvježavanje ključeva za potpisivanje
#pacman-key --refresh-key

# Instalacija
echo -e "\n***********************************************************\n"

# Jezgra i osnovni paketi za korištenje sustava
KERNEL_AND_BASE=$(cat ./kernel_and_base_packages.txt)

# GRUB bootloader paketi
if [[ "$SYSTEM_TYPE" == "UEFI" ]]; then
	BOOTLOADER=$(cat ./bootloader/bootloader_packages_uefi.txt)
else
	BOOTLOADER=$(cat ./bootloader/bootloader_packages_bios.txt)
fi

# Mikrokod
if [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
	echo "Detected AMD CPU ..."
	MICROCODE="amd-ucode"
elif [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
	echo "Detected Intel CPU ..."
	MICROCODE="intel-ucode"
else
	echo "No AMD or Intel CPU detected ..."
	MICROCODE=""
fi

read -p "Are you running in this in a VM? [y (default)/n]: " VM

# Paketi za korisnika
if [[ "$VM" != "n" || "$VM" != "N" ]]; then
	echo "Not installing microcode then ..."
	MICROCODE=""
fi

# Grafika
if [[ "$GPU_VENDOR" == "AMD" ]]; then
	echo "Detected AMD graphics ..."
	GRAPHICS="mesa"
elif [[ "$GPU_VENDOR" == "NVDIA" ]]; then
	echo "Detected NVIDIA graphics ..."
	GRAPHICS="nvidia-open"
else
	echo "No AMD or NVIDIA GPU detected ..."
	GRAPHICS=""
fi

# Uobičajeni paketi (uređivač teksta, razni mrežni paketi)
DEFAULT_PACKAGES=$(cat ./default_packages.txt)

read -p "Minimalist install? [y (default)/n]: " INPUT_1

# Paketi za korisnika
if [[ "$INPUT_1" == "n" || "$INPUT_1" == "N" ]]; then
	echo "You chose non-minimalist installation, custom package list will be read!"
	cat ./custom_packages.txt | tee /tmp/archlinux-install-script-files/custom_packages.txt
	cat ./custom_gui_packages.txt | tee /tmp/archlinux-install-script-files/custom_gui_packages.txt
else
	echo "You chose minimalist installation!"
fi

# Odabir desktop okruženja
./desktop-environment/choose_environment.sh

# Instalacija paketa
pacstrap -K /mnt/ $KERNEL_AND_BASE $BOOTLOADER $MICROCODE $GRAPHICS $DEFAULT_PACKAGES \
$(cat /tmp/archlinux-install-script-files/custom_packages.txt) \
$(cat /tmp/archlinux-install-script-files/custom_gui_packages.txt) \
$DESKTOP_ENVIRONMENT_PACKAGES

# Generiranje fstab datoteke
genfstab -U /mnt/ | tee /mnt/etc/fstab

# Početne postavke
check_script_retval "./system-setup/basic_settings.sh"

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

debug "SCRIPT '{PROJECT_ROOT}/system-setup/setup.sh' FINISHED EXECUTING (CODE: 0)"
exit 0
