#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/partitioning/choose_scheme.sh'"

# Funkcije
check_scheme() {

	# Ispitaj je li shema treba biti GPT ili MBR 
	if [[ "$SYSTEM_TYPE" == "UEFI" ]]; then
		SCHEME=gpt
	else
		SCHEME=mbr
	fi
	echo $SCHEME | tee /tmp/archlinux-install-script-files/target_scheme.txt

}

is_valid_number() {

	# Izvuci varijable
	local target_scheme=$1
	local max_number=$2
	local min_number=1

	# Usporedi je li odabran ispravan broj
	if echo "$target_scheme" | grep -qE '^[0-9]+$'; then
		if (( target_scheme >= min_number && target_scheme <= max_number )); then
			return 0
		else
			return 1
		fi
	else
		return 1
	fi

}

# Čita /tmp/archlinux-install-script-files/important_specs.txt
source /tmp/archlinux-install-script-files/important_specs.txt
check_scheme

# Piše disk koji se particionira u /tmp/archlinux-install-script-files/target_disk.txt
echo -e "\n==============CHOOSE SCHEME FOR PARTITIONING===============\n"

# Dok se ne upiše ispravno ime diska ili se ne izađe iz izvođenja
while true; do

	SCHEME_DESC_FILES=$(ls $WORK_DIR/partitioning/schemes/$SCHEME/descriptions/)

	# Broj dostupnih shema
	SCHEME_NUMBER=$(echo "$SCHEME_DESC_FILES" | wc -w)

	echo -e "View schemes: v\nChoose scheme: c\nQuit: q\n"
	read -p "Choice: " INPUT_0
	echo ""

	# Ako je odabran prekid
	if [[ "$INPUT_0" == "q" ]]; then
		debug "SCRIPT '{PROJECT_ROOT}/partitioning/choose_scheme.sh' FINISHED EXECUTING (CODE: 1)"
		exit 1
	fi

	# Ako je samo stisnuta tipka Enter
	if [[ "$INPUT_0" == "" ]]; then
		echo -e "Selected no option!\n"
		continue
	fi

	# Ako je odabran ispis shema
	if [[ "$INPUT_0" == "v" ]]; then

		while true; do

			echo -e "View all schemes: a\nView one scheme: 1-$SCHEME_NUMBER\nBack to main menu: q\n"
			read -p "Choice: " INPUT_1
			echo ""

			# Vraćanje na glavni izbornik
			if [[ "$INPUT_1" == "q" ]]; then
				break
			fi

			# Ako je samo stisnuta tipka Enter
			if [[ "$INPUT_1" == "" ]]; then
				continue
			fi

			# Ako je odabran prikaz svih shema
			if [[ "$INPUT_1" == "a" ]]; then

				while true; do

					echo -e "Short description: s\nLong description: l\nBack to menu: q\n"
					read -p "Choice: " INPUT_2
					echo ""

					# Vraćanje na izbornik
					if [[ "$INPUT_2" == "q" ]]; then
						break
					fi

					# Ako je samo stisnuta tipka Enter
					if [[ "$INPUT_2" == "" ]]; then
						continue
					fi

					# Ako je odabran kraći prikaz svih shema
					if [[ "$INPUT_2" == "s" ]]; then

						# Ispisivanje kratkog opisa svih shema
						echo -e "Available scheme short descriptions:"

						echo -e "\n***********************************************************\n"
						COUNTER=1
						for INDEX in $SCHEME_DESC_FILES; do

							FIRST_LINE=$(head -n 1 "$WORK_DIR/partitioning/schemes/$SCHEME/descriptions/$INDEX")
							echo "["$COUNTER"] $FIRST_LINE"
							((COUNTER++))

						done
						echo -e "\n***********************************************************\n"

					fi

					# Ako je odabran duži prikaz svih shema
					if [[ "$INPUT_2" == "l" ]]; then

						# Ispisivanje kratkog opisa svih shema
						echo -e "Available scheme descriptions:"
						COUNTER=1
						for INDEX in $SCHEME_DESC_FILES; do

							echo -e "\n["$COUNTER"]********************************************************\n"
							while IFS= read -r LINE; do
								echo "$LINE"
							done < $WORK_DIR/partitioning/schemes/$SCHEME/descriptions/$INDEX
							((COUNTER++))

						done
						echo -e "\n***********************************************************\n"

					fi

				done

			fi

			# Ako je odabran prikaz jedne sheme
			if is_valid_number "$INPUT_1" "$SCHEME_NUMBER"; then
			
				while true; do

					echo -e "Short description: s\nLong description: l\nBack to menu: q\n"
					read -p "Choice: " INPUT_3
					echo ""

					# Vraćanje na izbornik
					if [[ "$INPUT_3" == "q" ]]; then
						break
					fi

					# Ako je samo stisnuta tipka Enter
					if [[ "$INPUT_3" == "" ]]; then
						continue
					fi

					# Ako je odabran kraći prikaz konkretne sheme
					if [[ "$INPUT_3" == "s" ]]; then

						# Ispisivanje kratkog opisa jedne shema
						echo -e "Selected scheme description:"
						echo -e "\n***********************************************************\n"
						FIRST_LINE=$(head -n 1 "$WORK_DIR/partitioning/schemes/$SCHEME/descriptions/scheme_$INPUT_1.txt")
						echo "["$INPUT_1"] $FIRST_LINE"
						echo -e "\n***********************************************************\n"

					fi

					# Ako je odabran duži prikaz konkretne sheme
					if [[ "$INPUT_3" == "l" ]]; then

						# Ispisivanje kratkog opisa jedne shema
						echo -e "Selected scheme description:"
						echo -e "\n["$INPUT_1"]********************************************************\n"
						while IFS= read -r LINE; do
							echo "$LINE"
						done < $WORK_DIR/partitioning/schemes/$SCHEME/descriptions/scheme_$INPUT_1.txt
						echo -e "\n***********************************************************\n"

					fi
				
				done

			fi

		done

	fi

	# Ako je odabran odabir sheme
	if [[ "$INPUT_0" == "c" ]]; then

		while true; do

			echo -e "Choose one scheme: 1-$SCHEME_NUMBER\nBack to main menu: q\n"
			read -p "Choice: " INPUT_4
			echo ""

			if [[ "$INPUT_4" == "q" ]]; then
				# Vraćanje na glavni izbornik
				break
			fi

			# Ako je samo stisnuta tipka Enter
			if [[ "$INPUT_4" == "" ]]; then
				continue
			fi

			# Ako je odabir diska validan
			if is_valid_number "$INPUT_4" "$SCHEME_NUMBER"; then
				FIRST_LINE=$(head -n 1 "$WORK_DIR/partitioning/schemes/$SCHEME/descriptions/scheme_$INPUT_4.txt")
				echo -e "Target scheme chosen: ["$INPUT_4"] $FIRST_LINE"
				echo $INPUT_4 | tee /tmp/archlinux-install-script-files/target_scheme_index.txt > /dev/null
				echo ""
				debug "SCRIPT '{PROJECT_ROOT}/partitioning/choose_scheme.sh' FINISHED EXECUTING (CODE: 0)"
				exit 0
			else
				echo -e "Selected scheme not present!\n"
			fi

		done

	fi

done

debug "SCRIPT '{PROJECT_ROOT}/partitioning/choose_scheme.sh' FINISHED EXECUTING (CODE: 0)"
exit 0
