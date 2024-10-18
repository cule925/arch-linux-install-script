#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/constraints/check_if_constraints_are_met.sh'"

# Čita /tmp/archlinux-install-script-files/important_specs.txt
source /tmp/archlinux-install-script-files/important_specs.txt

# Provjera zadovoljava li sustav instalacijska ograničenja
if [[ "$ARCH" != "x86_64" ]]; then
	echo "Unsupported architecture: $ARCH, exiting ..."
	debug "SCRIPT '{PROJECT_ROOT}/constraints/check_if_constraints_are_met.sh' FINISHED EXECUTING (CODE: 1)"
	exit 1
fi

debug "SCRIPT '{PROJECT_ROOT}/constraints/check_if_constraints_are_met.sh' FINISHED EXECUTING (CODE: 0)"
exit 0
