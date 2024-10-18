#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/partitioning/schemes/gpt/scheme_1.sh'"

echo "Partitioning as GPT using scheme_1 (EFI + ROOT + HOME)"

# Funkcije
is_valid_input() {

	local input="$1"

	# Ako je ulaz prazan
	if [[ -z "$input" ]]; then
		return 0
	fi

	# Validiraj broj ako ima jedan od sufiksa K, M, G, T, P ili ga uopće nema
	if [[ "$input" =~ ^[0-9]+[KkMmGgTtPp]?$ ]]; then
		return 0
	else
		return 1
	fi

}

get_input() {

	local input
	local partition="$1"
	local size="$2"

	# Pisanje veličina particije
	while true; do
		read -p "Enter $partition size [size{K,M,G,T,P}]: " input
		if is_valid_input "$input"; then
			if [[ "$input" != "" ]]; then
				input="+$input"
			fi
			break
		else
			echo "Invalid input, try again."
		fi
	done
	
	eval "$size=\"$input\""

}

# Provjeri je li disk NVME
TARGET_DISK="$(cat /tmp/archlinux-install-script-files/target_disk.txt)"

if echo "$TARGET_DISK" | grep -q "nvme"; then
	APPEND_P=p
else
	APPEND_P=
fi

# Particije
EFI=1
ROOT=2
HOME=3

EFI_TYPE=1		# EFI
ROOT_TYPE=20		# Linux
HOME_TYPE=20		# Linux

# Upis veličina particija
while true; do

	echo -e "\n***********************************************************\n"

	echo -e "\nDisk that is about to be partitioned:\n"
	lsblk -pdo NAME,SIZE,TYPE $TARGET_DISK
	echo ""

	EFI_SIZE=+512M
	echo "Default EFI size is $EFI_SIZE"

	get_input "ROOT" "ROOT_SIZE"
	get_input "HOME" "HOME_SIZE"
	
	echo -e "\nEFI size: $EFI_SIZE"
	echo -e "ROOT size: $ROOT_SIZE"
	echo -e "HOME size:\n $HOME_SIZE"

	read -p "Are you sure that these are your final values? [y/n]: " INPUT_1
	if [[ "$INPUT_1" == "y" || "$INPUT_1" == "Y" || "$INPUT_1" == "" ]]; then
		break
	fi

done

echo -e "\n***********************************************************\n"

# Ako se odabere prekid, prekini
check_script_retval "./choice-script/yes_or_no.sh"

echo -e "\n***********************************************************\n"

echo -e "This will be executed in fdisk:"
cat <<EOF
g					# GPT scheme
n					# New partition
$EFI					# Partition number
					# First sector (default)
$EFI_SIZE				# Partition size
n					# New partition
$ROOT					# Partition number
					# First sector (default)
$ROOT_SIZE				# Partition size
n					# New partition
$HOME					# Partition number
					# First sector (default)
$HOME_SIZE				# Partition size
t					# Partition type
$EFI
$EFI_TYPE
t					# Partition type
$ROOT
$ROOT_TYPE
t					# Partition type
$HOME
$HOME_TYPE
p					# Print output
w
EOF

echo -e "\n***********************************************************\n"

# Particioniranje
fdisk -W always $TARGET_DISK <<EOF
g
n
$EFI

$EFI_SIZE
n
$ROOT

$ROOT_SIZE
n
$HOME

$HOME_SIZE
t
$EFI
$EFI_TYPE
t
$ROOT
$ROOT_TYPE
t
$HOME
$HOME_TYPE
p
w
EOF

# Pisanje particija u datoteku
TARGET_DISK_PARTITIONS_FILE="/tmp/archlinux-install-script-files/target_disk_partitions.txt"

EFI_PARTITION_DEV_FILE="$TARGET_DISK$APPEND_P$EFI"
ROOT_PARTITION_DEV_FILE="$TARGET_DISK$APPEND_P$ROOT"
HOME_PARTITION_DEV_FILE="$TARGET_DISK$APPEND_P$HOME"

echo "$EFI_PARTITION_DEV_FILE" | tee $TARGET_DISK_PARTITIONS_FILE > /dev/null
echo "$ROOT_PARTITION_DEV_FILE" | tee -a $TARGET_DISK_PARTITIONS_FILE > /dev/null
echo "$HOME_PARTITION_DEV_FILE" | tee -a $TARGET_DISK_PARTITIONS_FILE > /dev/null

# Formatiraj particije

echo -e "Formating partitions ...\n"

echo "Formatting the EFI partition ($EFI_PARTITION_DEV_FILE):" 
mkfs.vfat -F 32 $EFI_PARTITION_DEV_FILE
echo "Formatting the partition ($ROOT_PARTITION_DEV_FILE):"
mkfs.ext4 $ROOT_PARTITION_DEV_FILE
echo "Formatting the HOME partition ($HOME_PARTITION_DEV_FILE):"
mkfs.ext4 $HOME_PARTITION_DEV_FILE

echo -e "\n***********************************************************\n"

echo -e "Mounting partitions ...\n"

# Montiranje particija
echo "Mounting the ROOT partition ($ROOT_PARTITION_DEV_FILE):" 
mount $ROOT_PARTITION_DEV_FILE /mnt
echo "Mounting the EFI partition ($EFI_PARTITION_DEV_FILE):"
mount --mkdir $EFI_PARTITION_DEV_FILE /mnt/efi
echo "Mounting the HOME partition ($HOME_PARTITION_DEV_FILE):"
mount --mkdir $HOME_PARTITION_DEV_FILE /mnt/home

echo ""

lsblk -po NAME,SIZE,TYPE,MOUNTPOINTS $TARGET_DISK

check_script_retval "./system-setup/setup.sh"

umount -R /mnt

debug "SCRIPT '{PROJECT_ROOT}/partitioning/schemes/gpt/scheme_1.sh' FINISHED EXECUTING (CODE: 0)"
exit 0
