#!/bin/bash

# OVAJ DIO JE DRUGAČIJI ZA SVAKU SHEMU
# | | | | | | | | | | | | | | | | | |
# v v v v v v v v v v v v v v v v v v

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/partitioning/schemes/mbr/scheme_3.sh'"

echo "Partitioning as MBR using scheme_3 (BOOT + ENCRYPTED ROOT)"

# ____________________________________
# | | | | | | | | | | | | | | | | | | 
# OVAJ DIO JE DRUGAČIJI ZA SVAKU SHEMU

# Funkcije
source ./partitioning/scheme_functions.sh

# Provjeri je li disk NVME
TARGET_DISK="$(cat /tmp/archlinux-install-script-files/target_disk.txt)"

if echo "$TARGET_DISK" | grep -q "nvme"; then
	APPEND_P=p
else
	APPEND_P=
fi

# OVAJ DIO JE DRUGAČIJI ZA SVAKU SHEMU
# | | | | | | | | | | | | | | | | | |
# v v v v v v v v v v v v v v v v v v

# Particije
BOOT=1
ROOT=2

BOOT_TYPE=83		# Linux
ROOT_TYPE=83		# Linux

# Upis veličina particija
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
# OVAJ DIO JE DRUGAČIJI ZA SVAKU SHEMU

# Nastavi: Da ili ne?
choice_yes_or_no

# OVAJ DIO JE DRUGAČIJI ZA SVAKU SHEMU
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

# Particioniranje
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

# Ako postoji ekriptirana ROOT particija
ENCRYPTED_ROOT="Y"
touch /tmp/archlinux-install-script-files/mapped_partition_name.txt
export ENCRYPTED_ROOT
ENCRYPTED_BOOT="N"
export ENCRYPTED_BOOT

# Pisanje particija u datoteku
TARGET_DISK_PARTITIONS_FILE="/tmp/archlinux-install-script-files/target_disk_partitions.txt"

BOOT_PARTITION_DEV_FILE="$TARGET_DISK$APPEND_P$BOOT"
ENCRYPTED_ROOT_PARTITION_DEV_FILE="$TARGET_DISK$APPEND_P$ROOT"

echo -e "Formating LUKS partition on ROOT:"

# Formatiranje ROOT particije kao LUKS
while true; do
	cryptsetup -v luksFormat "$ENCRYPTED_ROOT_PARTITION_DEV_FILE"
	if [ $? -eq 0 ]; then
		break
	fi
done

# Otvaranje enkriptirane ROOT particije, tražit će zaporku
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

# Formatiraj particije
echo -e "Formating partitions ...\n"

echo "Formatting the BOOT partition ($BOOT_PARTITION_DEV_FILE):"
mkfs.ext4 $BOOT_PARTITION_DEV_FILE
echo "Formatting the decrypted ROOT partition ($CRYPT_DEV_FILE):"
mkfs.ext4 $CRYPT_DEV_FILE

echo -e "\n***********************************************************\n"

echo -e "Mounting partitions ...\n"

# Montiranje particija
echo "Mounting the decrypted ROOT partition ($CRYPT_DEV_FILE):" 
mount $CRYPT_DEV_FILE /mnt
echo "Mounting the BOOT partition ($BOOT_PARTITION_DEV_FILE):"
mount --mkdir $BOOT_PARTITION_DEV_FILE /mnt/boot

echo ""

# ____________________________________
# | | | | | | | | | | | | | | | | | | 
# OVAJ DIO JE DRUGAČIJI ZA SVAKU SHEMU

lsblk -po NAME,SIZE,TYPE,MOUNTPOINTS $TARGET_DISK

check_script_retval "./system/setup.sh"

# OVAJ DIO JE DRUGAČIJI ZA SVAKU SHEMU
# | | | | | | | | | | | | | | | | | |
# v v v v v v v v v v v v v v v v v v

debug "SCRIPT '{PROJECT_ROOT}/partitioning/schemes/mbr/scheme_3.sh' FINISHED EXECUTING (CODE: 0)"

# ____________________________________
# | | | | | | | | | | | | | | | | | | 
# OVAJ DIO JE DRUGAČIJI ZA SVAKU SHEMU

exit 0
