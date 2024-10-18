#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/choice-script/yes_or_no.sh'"

# Čita ulaz
read -p "Do you want to proceed? [y/n]: " INPUT

# Provjeri je li ulaz y, Y, ili tipka Enter
if [[ "$INPUT" == "y" || "$INPUT" == "Y" || -z "$INPUT" ]]; then
	echo "Proceeding ..."
	debug "SCRIPT '{PROJECT_ROOT}/choice-script/yes_or_no.sh' FINISHED EXECUTING (CODE: 0)"
	exit 0
else
	echo "Not proceeding."
	debug "SCRIPT '{PROJECT_ROOT}/choice-script/yes_or_no.sh' FINISHED EXECUTING (CODE: 1)"
	exit 1
fi
