#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/partitioning/choose_disk.sh'"

# Funkcije
is_valid_target_disk() {

	# Izvuci varijable
	local t_disk=$1
	local v_disks=$2

	# Usporedi nalazi li se odabrani disk između izlistanim
	if echo "$v_disks" | grep -q "^$t_disk$"; then
		return 0
	else
		return 1
	fi

}

# Piše disk koji se particionira u /tmp/archlinux-install-script-files/target_disk.txt
echo -e "\n===============CHOOSE DISK FOR PARTITIONING================\n"

# Dok se ne upiše ispravno ime diska ili se ne izađe iz izvođenja
while true; do

	echo -e "Available disks and partitions:\n"
	lsblk

	echo -e "\nAvailable disks:\n"
	lsblk -pdo NAME,SIZE,TYPE

	VALID_DISKS=$(lsblk -pdo NAME | tail +2)

	echo -e "\nChoose disk wisely! Write full device path. [q to quit]\n"
	read -p "Disk path: " TARGET_DISK
	echo ""

	# Ako je odabran prekid
	if [[ "$TARGET_DISK" == "q" ]]; then
		debug "SCRIPT '{PROJECT_ROOT}/partitioning/choose_disk.sh' FINISHED EXECUTION (CODE: 1)"
		exit 1
	fi

	# Ako je samo stisnuta tipka Enter
	if [[ "$TARGET_DISK" == "" ]]; then
		echo -e "Selected no disk!\n"
		continue
	fi

	# Ako je odabir diska validan
	if is_valid_target_disk "$TARGET_DISK" "$VALID_DISKS"; then
		echo -e "Target disk chosen:"
		echo $TARGET_DISK | tee /tmp/archlinux-install-script-files/target_disk.txt
		break
	else
		echo -e "Selected disk doesn't exist!\n"
	fi

done

debug "SCRIPT '{PROJECT_ROOT}/partitioning/choose_disk.sh' FINISHED EXECUTION (CODE: 0)"
exit 0
