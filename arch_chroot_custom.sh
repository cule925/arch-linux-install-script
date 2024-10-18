#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/arch_chroot_custom.sh'"

USER=$(cat /tmp/archlinux-install-script-files/user.txt)

echo -e "\n========>>>>>>>> ARCH-CHROOT-CUSTOM-COMMANDS\n"

arch-chroot /mnt /bin/bash <<EOF
history -c && exit
EOF

debug "SCRIPT '{PROJECT_ROOT}/arch_chroot_custom.sh' FINISHED EXECUTING (CODE: 0)"
exit 0
