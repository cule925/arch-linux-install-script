#!/bin/bash

# THIS PART IS DIFFERENT FOR EVERY SCHEME
# | | | | | | | | | | | | | | | | | |
# v v v v v v v v v v v v v v v v v v

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/partitioning/schemes/mbr/scheme_3.sh'"

echo "Partitioning as MBR using scheme_3 (BOOT + ENCRYPTED ROOT)"

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

# Partitions
BOOT=1
ROOT=2

BOOT_TYPE=83		# Linux
ROOT_TYPE=83		# Linux

# Inserting the sizes of the partitions
while true; do

	echo -e "\n***********************************************************\n"

	echo -e "\nDisk that is about to be partitioned:\n"
	lsblk -pdo NAME,SIZE,TYPE $TARGET_DISK
	echo ""

	BOOT_SIZE=+512M
	echo "Default BOOT size is $BOOT_SIZE"

	get_input "ROOT" "ROOT_SIZE"
	
	if [[ "$ROOT_SIZE" == "" ]]; then
		echo -e "ROOT size: rest of free disk space\n"	
	else
		echo -e "ROOT size: $ROOT_SIZE\n"
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
$BOOT					# Partition number
					# First sector (default)
$BOOT_SIZE				# Partition size
n					# New partition
p					# Primary partition
$ROOT					# Partition number
					# First sector (default)
$ROOT_SIZE				# Partition size
t					# Partition type
$BOOT
$BOOT_TYPE
t					# Partition type
$ROOT
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
$BOOT

$BOOT_SIZE
n
p
$ROOT

$ROOT_SIZE
t
$BOOT
$BOOT_TYPE
t
$ROOT
$ROOT_TYPE
p
w
EOF

# Encryption options
ENCRYPTED_ROOT="Y"
touch /tmp/archlinux-install-script-files/mapped_partition_name.txt
export ENCRYPTED_ROOT
ENCRYPTED_BOOT="N"
export ENCRYPTED_BOOT

# Writing the partition names into files
TARGET_DISK_PARTITIONS_FILE="/tmp/archlinux-install-script-files/target_disk_partitions.txt"

BOOT_PARTITION_DEV_FILE="$TARGET_DISK$APPEND_P$BOOT"
ENCRYPTED_ROOT_PARTITION_DEV_FILE="$TARGET_DISK$APPEND_P$ROOT"

echo -e "Formating LUKS partition on ROOT:"

# Formating the ROOT partition as a LUKS partition
while true; do
	cryptsetup -v luksFormat "$ENCRYPTED_ROOT_PARTITION_DEV_FILE"
	if [ $? -eq 0 ]; then
		break
	fi
done

# Opening the encrypted ROOT partition
CRYPT_NAME="cryptroot"

while true; do
	cryptsetup open "$ENCRYPTED_ROOT_PARTITION_DEV_FILE" "$CRYPT_NAME"
	if [ $? -eq 0 ]; then
		break
	fi
done

echo "$ENCRYPTED_ROOT_PARTITION_DEV_FILE" | tee /tmp/archlinux-install-script-files/encrypted_partition.txt > /dev/null
echo "$CRYPT_NAME" | tee /tmp/archlinux-install-script-files/mapped_partition_name.txt > /dev/null

CRYPT_DEV_FILE="/dev/mapper/$CRYPT_NAME"

echo "$BOOT_PARTITION_DEV_FILE" | tee -a $TARGET_DISK_PARTITIONS_FILE > /dev/null
echo "$CRYPT_DEV_FILE" | tee -a $TARGET_DISK_PARTITIONS_FILE > /dev/null

# Formating the partitions
echo -e "Formating partitions ...\n"

echo "Formatting the BOOT partition ($BOOT_PARTITION_DEV_FILE):"
mkfs.ext4 $BOOT_PARTITION_DEV_FILE
echo "Formatting the decrypted ROOT partition ($CRYPT_DEV_FILE):"
mkfs.ext4 $CRYPT_DEV_FILE

echo -e "\n***********************************************************\n"

echo -e "Mounting partitions ...\n"

# Mounting the partitions
echo "Mounting the decrypted ROOT partition ($CRYPT_DEV_FILE):" 
mount $CRYPT_DEV_FILE /mnt
echo "Mounting the BOOT partition ($BOOT_PARTITION_DEV_FILE):"
mount --mkdir $BOOT_PARTITION_DEV_FILE /mnt/boot

echo ""

# ____________________________________
# | | | | | | | | | | | | | | | | | | 
# THIS PART IS DIFFERENT FOR EVERY SCHEME

lsblk -po NAME,SIZE,TYPE,MOUNTPOINTS $TARGET_DISK

check_script_retval "./system/setup.sh"

# THIS PART IS DIFFERENT FOR EVERY SCHEME
# | | | | | | | | | | | | | | | | | |
# v v v v v v v v v v v v v v v v v v

debug "SCRIPT '{PROJECT_ROOT}/partitioning/schemes/mbr/scheme_3.sh' FINISHED EXECUTING (CODE: 0)"

# ____________________________________
# | | | | | | | | | | | | | | | | | | 
# THIS PART IS DIFFERENT FOR EVERY SCHEME

exit 0
