#!/bin/bash

is_valid_input() {

	local input="$1"

	# If input is empty
	if [[ -z "$input" ]]; then
		return 0
	fi

	# Validate if number has sufixes like K, M, G, T, P or doesn't have a sufix
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

	# Writing the size of the partition
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
