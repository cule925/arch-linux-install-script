#!/bin/bash

# Funkcije

# Počisti za sobom
clean() {

	echo "Cleaning up ..."
	umount -R -q /mnt
	rm -r /tmp/archlinux-install-script-files 2> /dev/null
	echo -e "Done!\n"

}

# Počisti za sobom u slučaju prekida
clean_on_interrupt() {

	echo -e "\nInterrupt detected!"
	clean
	exit 0

}

# Debagiranje
debug() {

	if [[ "$DEBUG" == "1" ]]; then
		echo -e "\n[DEBUG]: $1\n" 
	fi

}

# Opcija nastavi: Da ili ne?
choice_yes_or_no() {

	local input
	read -p "Do you want to proceed? [y/n]: " input

	# Provjeri je li ulaz y, Y, ili tipka Enter
	if [[ "$input" == "y" || "$input" == "Y" || -z "$input" ]]; then
		echo "Proceeding ..."
	else
		echo "Not proceeding."
		clean
		exit 1
	fi

}

# Opcija koja provjerava je li scripta uspješno dovršena
check_script_retval() {

	# Izvuci argument
	local command="$1"

	# Izvrši skriptu ili naredbu
	if ! eval "$command"; then
		clean
		exit 1
	fi

}

export -f check_script_retval
export -f choice_yes_or_no
export -f debug

# Ovo je instalacijska skripta za Arch Linux za x86_64 arhitekture.
echo -e "\n====================ARCH INSTALL SCRIPT====================\n"

trap clean_on_interrupt SIGINT

read -p "Debug mode? [y/n (default)]: " INPUT_1

# Debagiranje?
if [[ "$INPUT_1" == "y" || "$INPUT_1" == "Y" ]]; then
	echo "Debug mode set."
	debug "SCRIPT '{PROJECT_ROOT}/install.sh' FINISHED EXECUTING (CODE: 1)"
	DEBUG="1"
fi
export DEBUG

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/install.sh'"

# Stvori /tmp/archlinux-install-script-files direktorij ako ne postoji
if [[ ! -d "/tmp/archlinux-install-script-files" ]]; then
	mkdir /tmp/archlinux-install-script-files
	echo "/tmp/archlinux-install-script-files directory created."
else
	echo "/tmp/archlinux-install-script-files directory already exists."
fi

CANCEL_INSTALL="echo 'Installation canceled!'; exit 1"

# Provjera hardverskih specifikacija za instalaciju
echo -e "\nWelcome to the Arch install script
made by Iwan Ćulumović ..."

# Trenutni direktorij
WORK_DIR=$(pwd)
export WORK_DIR

# Provjera sustavskih specifikacija, rezultati se spremaju u datoteku ./system-info/important_specs.txt
check_script_retval "./system/check_system_info.sh"

# Ako se odabere prekid, prekini
choice_yes_or_no

# Odabir diska za particioniranje, sprema se na temp/target_disk.txt
check_script_retval "./partitioning/choose_disk.sh"

# Odabir sheme particioniranja, informacijske datoteke se spremaju na /tmp/archlinux-install-script-files/partitioning_style.txt i /tmp/archlinux-install-script-files/target_scheme_index.txt
check_script_retval "./partitioning/choose_scheme.sh"

# Particioniranje i postavljanje sustava
PARTITIONING_STYLE=$(cat /tmp/archlinux-install-script-files/partitioning_style.txt)
TARGET_SCHEME_INDEX=$(cat /tmp/archlinux-install-script-files/target_scheme_index.txt)
check_script_retval "./partitioning/schemes/$PARTITIONING_STYLE/scheme_$TARGET_SCHEME_INDEX.sh"

# Počisti za sobom
clean

# Ponovno pokretanje
read -p "Do you want to reboot? [y/n]: " INPUT_2

# Provjeri je li ulaz y, Y, ili tipka Enter
if [[ "$INPUT_2" == "y" || "$INPUT_2" == "Y" || "$INPUT_2" == "" ]]; then
	echo "Rebooting ..."
	debug "SCRIPT '{PROJECT_ROOT}/install.sh' FINISHED EXECUTING (CODE: 0)"
	reboot
else
	debug "SCRIPT '{PROJECT_ROOT}/install.sh' FINISHED EXECUTING (CODE: 0)"
	exit 0
fi
