#!/bin/bash

# THIS PART IS DIFFERENT FOR EVERY SCHEME
# | | | | | | | | | | | | | | | | | |
# v v v v v v v v v v v v v v v v v v

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/partitioning/schemes/mbr/scheme_4.sh'"

echo "Partitioning as MBR using scheme_4 (ENCRYPTED ROOT)"

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
ENCRYPTED_ROOT="Y"
touch /tmp/archlinux-install-script-files/mapped_partition_name.txt
export ENCRYPTED_ROOT
ENCRYPTED_BOOT="Y"
export ENCRYPTED_BOOT

# Writing the partition name into a file
TARGET_DISK_PARTITIONS_FILE="/tmp/archlinux-install-script-files/target_disk_partitions.txt"

ENCRYPTED_ROOT_PARTITION_DEV_FILE="$TARGET_DISK$APPEND_P$ROOT"

echo -e "Formating LUKS partition on ROOT:"

# Formating the ROOT partition as a LUKS partition
while true; do
	cryptsetup -v luksFormat --pbkdf pbkdf2 "$ENCRYPTED_ROOT_PARTITION_DEV_FILE"
	if [ $? -eq 0 ]; then
		break
	fi
done

CRYPT_NAME="cryptroot"

# Opening the encrypted ROOT partition
while true; do
	read -s -p "Enter passphrase again to decrypt the partition: " ENCRYPTED_PARTITION_PASSWORD
	echo $ENCRYPTED_PARTITION_PASSWORD | cryptsetup open "$ENCRYPTED_ROOT_PARTITION_DEV_FILE" "$CRYPT_NAME" > /dev/null 2>&1
	if [ $? -eq 1 ]; then
		echo "Failure to open encrypted partition!"
	else
		echo "$ENCRYPTED_PARTITION_PASSWORD" | tee "/tmp/archlinux-install-script-files/encrypted_partition_password.txt" > /dev/null
		break
	fi
done

echo "$ENCRYPTED_ROOT_PARTITION_DEV_FILE" | tee /tmp/archlinux-install-script-files/encrypted_partition.txt > /dev/null
echo "$CRYPT_NAME" | tee /tmp/archlinux-install-script-files/mapped_partition_name.txt > /dev/null

CRYPT_DEV_FILE="/dev/mapper/$CRYPT_NAME"

echo "$CRYPT_DEV_FILE" | tee -a $TARGET_DISK_PARTITIONS_FILE > /dev/null

# Formating the partition
echo -e "Formating partitions ...\n"

echo "Formatting the decrypted ROOT partition ($CRYPT_DEV_FILE):"
mkfs.ext4 $CRYPT_DEV_FILE

echo -e "\n***********************************************************\n"

echo -e "Mounting partitions ...\n"

# Mounting the partition
echo "Mounting the decrypted ROOT partition ($CRYPT_DEV_FILE):" 
mount $CRYPT_DEV_FILE /mnt

echo ""

# ____________________________________
# | | | | | | | | | | | | | | | | | | 
# THIS PART IS DIFFERENT FOR EVERY SCHEME

lsblk -po NAME,SIZE,TYPE,MOUNTPOINTS $TARGET_DISK

check_script_retval "./system/setup.sh"

# THIS PART IS DIFFERENT FOR EVERY SCHEME
# | | | | | | | | | | | | | | | | | |
# v v v v v v v v v v v v v v v v v v

debug "SCRIPT '{PROJECT_ROOT}/partitioning/schemes/gpt/scheme_4.sh' FINISHED EXECUTING (CODE: 0)"

# ____________________________________
# | | | | | | | | | | | | | | | | | | 
# THIS PART IS DIFFERENT FOR EVERY SCHEME

exit 0
