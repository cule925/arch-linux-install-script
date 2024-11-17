#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/system/arch_chroot_initial_setup.sh'"

source ./settings.txt

echo -e "\n<<<<<<<<========HOSTNAME========>>>>>>>>\n"

# Hostname
read -p "What would you like to name your system? Enter: " HOSTNAME
if [[ "$HOSTNAME" == "" ]]; then
	echo "Hostname not set, going by hostname 'arch'."
	HOSTNAME_COMMAND="echo \"arch\" | tee /etc/hostname"
else
	echo "Hostname set: $HOSTNAME"
	HOSTNAME_COMMAND="echo \"$HOSTNAME\" | tee /etc/hostname"
fi

echo -e "\n<<<<<<<<=====ROOT PASSWORD======>>>>>>>>\n"

# Root password
while true; do
	read -s -p "Enter root password: " ROOT_PASSWORD
	echo ""
	if [[ "$ROOT_PASSWORD" == "" ]]; then
		echo -e "Password cannot be empty!\n"
	else
		read -s -p "Reenter root password: " ROOT_PASSWORD_CHECK
		echo ""
		if [[ "$ROOT_PASSWORD" == "$ROOT_PASSWORD_CHECK" ]]; then
			echo "Password verfied!"
			break
		else
			echo "Passwords do not match!"
		fi
	fi
done

echo -e "\n<<<<<<<<==========USER==========>>>>>>>>\n"

# Regular user
while true; do
	read -p "Enter new user: " USER
	if [[ "$USER" == "" ]]; then
		echo -e "User cannot be empty!\n"
	else
		echo "User set: $USER"
		break
	fi
done
echo "$USER" | tee /tmp/archlinux-install-script-files/user.txt

echo -e "\n<<<<<<<<========PASSWORD========>>>>>>>>\n"

# Regular user password
while true; do
	read -s -p "Enter $USER password: " PASSWORD
	echo ""
	if [[ "$PASSWORD" == "" ]]; then
		echo -e "Password cannot be empty!\n"
	else
		read -s -p "Reenter root password: " PASSWORD_CHECK
		echo ""
		if [[ "$PASSWORD" == "$PASSWORD_CHECK" ]]; then
			echo "Password verfied!"
			break
		else
			echo "Passwords do not match!"
		fi
	fi
done

echo -e "\n========>>>>>>>> ARCH-CHROOT-BASIC-SETTINGS\n"

arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/$REGION/$CITY /etc/localtime
hwclock --systohc
sed -i 's/^#\\s*\\($LOCALE_DEFAULT_1\\s$LOCALE_DEFAULT_2\\)/\\1/' /etc/locale.gen
sed -i 's/^#\\s*\\($LOCALE_BACKUP_1\\s$LOCALE_BACKUP_2\\)/\\1/' /etc/locale.gen
locale-gen
echo "LANG=$LANG" | tee /etc/locale.conf
echo "KEYMAP=$KEYMAP" | tee /etc/vconsole.conf
echo "FONT=$FONT" | tee -a /etc/vconsole.conf
$HOSTNAME_COMMAND
systemctl enable systemd-timesyncd
systemctl enable NetworkManager
systemctl enable bluetooth
echo -e "$ROOT_PASSWORD\\n$ROOT_PASSWORD" | passwd
useradd -m -G wheel -s /bin/bash $USER
echo -e "$PASSWORD\\n$PASSWORD" | passwd $USER
sed -i 's/^#\\s*\\(%wheel ALL=(ALL:ALL) ALL\\)/\\1/' /etc/sudoers
echo -e "\\n127.0.0.1\\tlocalhost\\n127.0.1.1\\t\$(cat /etc/hostname)\\n::1\\t\\tip6-\$(cat /etc/hostname)" | tee -a /etc/hosts
history -c && exit
EOF

debug "SCRIPT '{PROJECT_ROOT}/system/arch_chroot_initial_setup.sh' FINISHED EXECUTING (CODE: 0)"
exit 0
