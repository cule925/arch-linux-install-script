#!/bin/bash

# THIS PART IS DIFFERENT FOR EVERY SCHEME
# | | | | | | | | | | | | | | | | | |
# v v v v v v v v v v v v v v v v v v

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/partitioning/schemes/mbr/scheme_2.sh'"

echo "Partitioning as MBR using scheme_2 (ROOT)"

# ____________________________________
# | | | | | | | | | | | | | | | | | | 
# THIS PART IS DIFFERENT FOR EVERY SCHEME

# Functions
source ./partitioning/scheme_functions.sh

# Check if disk is NVME
TARGET_DISK="$(cat /tmp/archlinux-install-script-files/target_disk.txt)"

if echo "$TARGET_DISK" | grep -q "nvme"; then
	APPEND_P=p
else
	APPEND_P=
fi

# THIS PART IS DIFFERENT FOR EVERY SCHEME
# | | | | | | | | | | | | | | | | | |
# v v v v v v v v v v v v v v v v v v

# Partition
ROOT=1

ROOT_TYPE=83		# Linux

# Inserting the size of the partition
while true; do

	echo -e "\n***********************************************************\n"

	echo -e "\nDisk that is about to be partitioned:\n"
	lsblk -pdo NAME,SIZE,TYPE $TARGET_DISK
	echo ""

	get_input "ROOT" "ROOT_SIZE"
	
	if [[ "$ROOT_SIZE" == "" ]]; then
		echo -e "\nROOT size: rest of free disk space\n"	
	else
		echo -e "\nROOT size: $ROOT_SIZE\n"
	fi

	read -p "Are you sure that these are your final values? [y/n]: " INPUT_1
	if [[ "$INPUT_1" == "y" || "$INPUT_1" == "Y" || "$INPUT_1" == "" ]]; then
		break
	fi

done

echo -e "\n***********************************************************\n"

# ____________________________________
# | | | | | | | | | | | | | | | | | | 
# THIS PART IS DIFFERENT FOR EVERY SCHEME

# Proceed: Yes or no?
choice_yes_or_no

# THIS PART IS DIFFERENT FOR EVERY SCHEME
# | | | | | | | | | | | | | | | | | |
# v v v v v v v v v v v v v v v v v v

echo -e "\n***********************************************************\n"

echo -e "This will be executed in fdisk:"
cat <<EOF
o					# MBR scheme
n					# New partition
p					# Primary partition
$ROOT					# Partition number
					# First sector (default)
$ROOT_SIZE				# Partition size
t					# Partition type
$ROOT_TYPE
p					# Print output
w
EOF

echo -e "\n***********************************************************\n"

# Partitioning
fdisk -W always $TARGET_DISK <<EOF
o
n
p
$ROOT

$ROOT_SIZE
t
$ROOT_TYPE
p
w
EOF

# Encryption options
ENCRYPTED_ROOT="N"
touch /tmp/archlinux-install-script-files/crypt_root.txt
export ENCRYPTED_ROOT
ENCRYPTED_BOOT="N"
export ENCRYPTED_BOOT

# Writing the partition name into a file
TARGET_DISK_PARTITIONS_FILE="/tmp/archlinux-install-script-files/target_disk_partitions.txt"

ROOT_PARTITION_DEV_FILE="$TARGET_DISK$APPEND_P$ROOT"

echo "$ROOT_PARTITION_DEV_FILE" | tee -a $TARGET_DISK_PARTITIONS_FILE > /dev/null

# Formating the partition
echo -e "Formating partitions ...\n"

echo "Formatting the ROOT partition ($ROOT_PARTITION_DEV_FILE):"
mkfs.ext4 $ROOT_PARTITION_DEV_FILE

echo -e "\n***********************************************************\n"

echo -e "Mounting partitions ...\n"

# Mounting the partition
echo "Mounting the ROOT partition ($ROOT_PARTITION_DEV_FILE):" 
mount $ROOT_PARTITION_DEV_FILE /mnt

echo ""

# ____________________________________
# | | | | | | | | | | | | | | | | | | 
# THIS PART IS DIFFERENT FOR EVERY SCHEME

lsblk -po NAME,SIZE,TYPE,MOUNTPOINTS $TARGET_DISK

check_script_retval "./system/setup.sh"

# THIS PART IS DIFFERENT FOR EVERY SCHEME
# | | | | | | | | | | | | | | | | | |
# v v v v v v v v v v v v v v v v v v

debug "SCRIPT '{PROJECT_ROOT}/partitioning/schemes/gpt/scheme_2.sh' FINISHED EXECUTING (CODE: 0)"

# ____________________________________
# | | | | | | | | | | | | | | | | | | 
# THIS PART IS DIFFERENT FOR EVERY SCHEME

exit 0
