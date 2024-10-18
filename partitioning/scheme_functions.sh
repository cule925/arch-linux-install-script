#!/bin/bash

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
