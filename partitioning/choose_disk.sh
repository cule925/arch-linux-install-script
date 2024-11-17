#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/partitioning/choose_disk.sh'"

# Functions
is_valid_target_disk() {

	# Get parameters
	local t_disk=$1
	local v_disks=$2

	# Check if valid disk was chosen
	if echo "$v_disks" | grep -q "^$t_disk$"; then
		return 0
	else
		return 1
	fi

}

echo -e "\n===============CHOOSE DISK FOR PARTITIONING================\n"

# Execute while valid disk isn't chosen or user chose exit
while true; do

	echo -e "Available disks and partitions:\n"
	lsblk

	echo -e "\nAvailable disks:\n"
	lsblk -pdo NAME,SIZE,TYPE

	VALID_DISKS=$(lsblk -pdo NAME | tail +2)

	echo -e "\nChoose disk wisely! Write full device path. [q to quit]\n"
	read -p "Disk path: " TARGET_DISK
	echo ""

	# If interrupt was chosen
	if [[ "$TARGET_DISK" == "q" ]]; then
		debug "SCRIPT '{PROJECT_ROOT}/partitioning/choose_disk.sh' FINISHED EXECUTION (CODE: 1)"
		exit 1
	fi

	# If only enter was pressed
	if [[ "$TARGET_DISK" == "" ]]; then
		echo -e "Selected no disk!\n"
		continue
	fi

	# If a valid disk was chosen
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
