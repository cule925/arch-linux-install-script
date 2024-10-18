#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/desktop-environment/enable_environment.sh'"

# Konfiguracija desktop okruženja
DESKTOP_ENVIRONMENT=$(cat /tmp/archlinux-install-script-files/desktop_environment.txt)
if [[ "$DESKTOP_ENVIRONMENT" == "GNOME" ]]; then
	arch-chroot /mnt /bin/bash <<-EOF
	systemctl enable gdm
	history -c && exit
	EOF
fi

debug "SCRIPT '{PROJECT_ROOT}/desktop-environment/enable_environment.sh' FINISHED EXECUTING (CODE: 0)"
exit 0
