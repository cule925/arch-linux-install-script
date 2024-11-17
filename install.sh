#!/bin/bash

# Functions

# Cleanup
clean() {

	echo "Cleaning up ..."

	umount -R /mnt

	if [[ -e "/tmp/archlinux-install-script-files/mapped_partition_name.txt" ]]; then
		MAPPED_PARTITION_NAME=$(cat /tmp/archlinux-install-script-files/mapped_partition_name.txt)
		if [[ "$MAPPED_PARTITION_NAME" != "" ]]; then
			cryptsetup close /dev/mapper/$MAPPED_PARTITION_NAME
		fi
	fi

	rm -r /tmp/archlinux-install-script-files 2> /dev/null
	echo -e "Done!\n"

}

# Cleanup in case of interrupt
clean_on_interrupt() {

	echo -e "\nInterrupt detected!"
	clean
	exit 0

}

# Debug
debug() {

	if [[ "$DEBUG" == "1" ]]; then
		echo -e "\n[DEBUG]: $1\n" 
	fi

}

# Yes or no option
choice_yes_or_no() {

	local input
	read -p "Do you want to proceed? [y/n]: " input

	if [[ "$input" == "y" || "$input" == "Y" || -z "$input" ]]; then
		echo "Proceeding ..."
	else
		echo "Not proceeding."
		clean
		exit 1
	fi

}

# Check if script executed successfully
check_script_retval() {

	# Get argument
	local command="$1"

	# Execute script or command
	if ! eval "$command"; then
		clean
		exit 1
	fi

}

export -f check_script_retval
export -f choice_yes_or_no
export -f debug

echo -e "\n====================ARCH INSTALL SCRIPT====================\n"

trap clean_on_interrupt SIGINT

# User wants debug mode?
read -p "Debug mode? [y/n (default)]: " INPUT_1

if [[ "$INPUT_1" == "y" || "$INPUT_1" == "Y" ]]; then
	echo "Debug mode set."
	debug "SCRIPT '{PROJECT_ROOT}/install.sh' FINISHED EXECUTING (CODE: 1)"
	DEBUG="1"
fi
export DEBUG

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/install.sh'"

# Create /tmp/archlinux-install-script-files directory if it doesn't exist
if [[ ! -d "/tmp/archlinux-install-script-files" ]]; then
	mkdir /tmp/archlinux-install-script-files
	echo "/tmp/archlinux-install-script-files directory created."
else
	echo "/tmp/archlinux-install-script-files directory already exists."
fi

CANCEL_INSTALL="echo 'Installation canceled!'; exit 1"

# Check hardware specs before installation
echo -e "\nWelcome to the Arch install script
made by Iwan Ćulumović ..."

# Current directory
WORK_DIR=$(pwd)
export WORK_DIR

# Check system specs, results are saved in ./system-info/important_specs.txt
check_script_retval "./system/check_system_info.sh"

choice_yes_or_no

# Choose disk for partitioning, result is saved at temp/target_disk.txt
check_script_retval "./partitioning/choose_disk.sh"

# Choose partitioning scheme, informational files are saved at /tmp/archlinux-install-script-files/partitioning_style.txt and /tmp/archlinux-install-script-files/target_scheme_index.txt
check_script_retval "./partitioning/choose_scheme.sh"

# Partitioning and system setup
PARTITIONING_STYLE=$(cat /tmp/archlinux-install-script-files/partitioning_style.txt)
TARGET_SCHEME_INDEX=$(cat /tmp/archlinux-install-script-files/target_scheme_index.txt)
check_script_retval "./partitioning/schemes/$PARTITIONING_STYLE/scheme_$TARGET_SCHEME_INDEX.sh"

# Cleanup
clean

# Reboot?
read -p "Do you want to reboot? [y/n]: " INPUT_2

if [[ "$INPUT_2" == "y" || "$INPUT_2" == "Y" || "$INPUT_2" == "" ]]; then
	echo "Rebooting ..."
	debug "SCRIPT '{PROJECT_ROOT}/install.sh' FINISHED EXECUTING (CODE: 0)"
	reboot
else
	debug "SCRIPT '{PROJECT_ROOT}/install.sh' FINISHED EXECUTING (CODE: 0)"
	exit 0
fi
