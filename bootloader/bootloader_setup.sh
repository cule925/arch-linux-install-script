#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/bootloader/bootloader_setup.sh'"

# Čita /tmp/archlinux-install-script-files/important_specs.txt i 
source /tmp/archlinux-install-script-files/important_specs.txt

# Čita /tmp/archlinux-install-script-files/target_disk.txt
TARGET_DISK=$(cat /tmp/archlinux-install-script-files/target_disk.txt)

echo -e "\n========>>>>>>>> ARCH-CHROOT-BOOTLOADER-SETTINGS\n"

# Instalira GRUB bootloader
if [[ "$SYSTEM_TYPE" == "UEFI" ]]; then
	GRUB_INSTALL_COMMAND="grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=grub_uefi --recheck"
else
	GRUB_INSTALL_COMMAND="grub-install --target=i386-pc $TARGET_DISK"
fi

arch-chroot /mnt /bin/bash <<EOF
$GRUB_INSTALL_COMMAND
grub-mkconfig -o /boot/grub/grub.cfg
history -c && exit
EOF

debug "SCRIPT '{PROJECT_ROOT}/bootloader/bootloader_setup.sh' FINISHED EXECUTING (CODE: 0)"
exit 0
