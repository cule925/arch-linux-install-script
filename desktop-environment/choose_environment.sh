#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/desktop-environment/choose_environment.sh'"

# Odabir desktop okruženja

read -p "Desktop environment? [no environment - 0 (default)|GNOME - 1]: " INPUT_2

# Odabir desktop okruženja
if [[ "$INPUT_2" == "1" ]]; then
	echo "You chose GNOME!"
	echo "GNOME" | tee /tmp/archlinux-install-script-files/desktop_environment.txt
	cat ./desktop-environment/gnome_packages.txt | tee /tmp/archlinux-install-script-files/desktop_environment_packages.txt
else
	echo "You chose no GUI!"
	echo "" | tee /tmp/archlinux-install-script-files/custom_gui_packages.txt
	echo "" | tee /tmp/archlinux-install-script-files/desktop_environment.txt
	echo "" | tee /tmp/archlinux-install-script-files/desktop_environment_packages.txt
fi

debug "SCRIPT '{PROJECT_ROOT}/desktop-environment/choose_environment.sh' FINISHED EXECUTING (CODE: 0)"
exit 0
