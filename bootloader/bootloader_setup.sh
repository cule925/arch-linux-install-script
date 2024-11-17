#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/bootloader/bootloader_setup.sh'"

source /tmp/archlinux-install-script-files/important_specs.txt

TARGET_DISK="$(cat /tmp/archlinux-install-script-files/target_disk.txt)"

echo -e "\n========>>>>>>>> ARCH-CHROOT-BOOTLOADER-SETTINGS\n"

# If boot is also encrypted, this is also where the Linux kernel is
if [[ "$ENCRYPTED_BOOT" == "Y" ]]; then

	SED_ENABLE_CRYPTODISK="'s/^#\\?\\s*\\(GRUB_ENABLE_CRYPTODISK=\\).*/\\1y/'"
	arch-chroot /mnt /bin/bash <<-EOF

		sed -i $SED_ENABLE_CRYPTODISK /etc/default/grub
		history -c && exit

	EOF

fi

# Installs the GRUB bootloader
if [[ "$SYSTEM_TYPE" == "UEFI" ]]; then
	GRUB_INSTALL_COMMAND="grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=grub_uefi --recheck"
else
	GRUB_INSTALL_COMMAND="grub-install --target=i386-pc $TARGET_DISK"
fi

arch-chroot /mnt /bin/bash <<-EOF

	echo -e "\nInstalling GRUB ...\n"
	$GRUB_INSTALL_COMMAND
	history -c && exit

EOF

# In case of encrypted partition configure bootloader
if [[ "$ENCRYPTED_ROOT" == "Y" ]]; then

	ENCRYPTED_PARTITION_DEV_FILE="$(cat /tmp/archlinux-install-script-files/encrypted_partition.txt)"
	ENCRYPTED_PARTITION_ID="$(blkid -o value -s UUID $ENCRYPTED_PARTITION_DEV_FILE)"
	MAPPED_PARTITION_NAME="$(cat /tmp/archlinux-install-script-files/mapped_partition_name.txt)"

	SED_ENRYPED_ROOT_ARG_1="'s/^GRUB_CMDLINE_LINUX=\"\\([^\"]*\\)\"/GRUB_CMDLINE_LINUX=\"\\1 cryptdevice=UUID=$ENCRYPTED_PARTITION_ID:$MAPPED_PARTITION_NAME root=\\/dev\\/mapper\\/$MAPPED_PARTITION_NAME\"/'"
	SED_ENRYPED_ROOT_ARG_2="'s/^GRUB_CMDLINE_LINUX=\" \\([^\"]*\\)\"/GRUB_CMDLINE_LINUX=\"\\1\"/'"

	arch-chroot /mnt /bin/bash <<-EOF

		echo -e "\nConfiguring kernel command line arguments ...\n"
		sed -i $SED_ENRYPED_ROOT_ARG_1 /etc/default/grub
		sed -i $SED_ENRYPED_ROOT_ARG_2 /etc/default/grub
		history -c && exit

	EOF

	# In case of encrypted boot
	if [[ "$ENCRYPTED_BOOT" == "Y" ]]; then

		KEYNAME="$MAPPED_PARTITION_NAME.key"
		SED_PUT_ENCRYPTION_KEY_IN_GRUB_CFG="'s/^GRUB_CMDLINE_LINUX=\"\\([^\"]*\\)\"/GRUB_CMDLINE_LINUX=\"\\1 cryptkey=rootfs:\\/etc\\/cryptsetup-keys.d\\/$KEYNAME\"/'"
		SED_PUT_ENCRYPTION_KEY_IN_MKINITCPIO_CONF_1="'s/^FILES=(\\([^)]*\\))/FILES=(\\1 \\/etc\\/cryptsetup-keys.d\\/$KEYNAME)/'"
		SED_PUT_ENCRYPTION_KEY_IN_MKINITCPIO_CONF_2="'s/^FILES=( \\([^)]*\\))/FILES=(\\1)/'"

		ENCRYPTED_PARTITION_PASSWORD="$(cat /tmp/archlinux-install-script-files/encrypted_partition_password.txt)"

		arch-chroot /mnt /bin/bash <<-EOF

			echo -e "\nConfiguring key ...\n"
			dd bs=512 count=4 if=/dev/random iflag=fullblock | install -m 0600 /dev/stdin /etc/cryptsetup-keys.d/$KEYNAME
			echo -e "$ENCRYPTED_PARTITION_PASSWORD\n" | cryptsetup -v luksAddKey $ENCRYPTED_PARTITION_DEV_FILE /etc/cryptsetup-keys.d/$KEYNAME
			sed -i $SED_PUT_ENCRYPTION_KEY_IN_GRUB_CFG /etc/default/grub
			sed -i $SED_PUT_ENCRYPTION_KEY_IN_MKINITCPIO_CONF_1 /etc/mkinitcpio.conf
			sed -i $SED_PUT_ENCRYPTION_KEY_IN_MKINITCPIO_CONF_2 /etc/mkinitcpio.conf
			history -c && exit

		EOF

	fi

fi

# Configuring and installing initramfs
if [[ "$ENCRYPTED_ROOT" == "Y" ]]; then

	arch-chroot /mnt /bin/bash <<-EOF

		echo -e "\nConfiguring initramfs ...\n"
		sed -i "s/^HOOKS=.*/HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)/" /etc/mkinitcpio.conf
		mkinitcpio -P
		history -c && exit

	EOF

fi

# Configuring the GRUB bootloader
arch-chroot /mnt /bin/bash <<-EOF

	echo -e "\nCreating GRUB configuration ...\n"
	grub-mkconfig -o /boot/grub/grub.cfg
	history -c && exit

EOF

debug "SCRIPT '{PROJECT_ROOT}/bootloader/bootloader_setup.sh' FINISHED EXECUTING (CODE: 0)"
exit 0
