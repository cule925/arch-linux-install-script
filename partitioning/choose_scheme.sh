#!/bin/bash

debug "EXECUTING SCRIPT '{PROJECT_ROOT}/partitioning/choose_scheme.sh'"

# Functions
set_partitioning_style() {

	# Check if partition scheme needs to be GPT or MBR
	if [[ "$SYSTEM_TYPE" == "UEFI" ]]; then
		PARTITIONING_STYLE="gpt"
	else
		PARTITIONING_STYLE="mbr"
	fi
	echo "Partitioning style: "
	echo "$PARTITIONING_STYLE" | tee /tmp/archlinux-install-script-files/partitioning_style.txt

}

is_valid_number() {

	# Get variables
	local target_scheme=$1
	local max_number=$2
	local min_number=1

	# Check if correct number was chosen
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

source /tmp/archlinux-install-script-files/important_specs.txt
set_partitioning_style

echo -e "\n==============CHOOSE SCHEME FOR PARTITIONING===============\n"

# While valid disk isn't chosen or user chose exit
while true; do

	SCHEME_DESC_FILES=$(ls $WORK_DIR/partitioning/schemes/$PARTITIONING_STYLE/descriptions/)

	# Number of partitioning schemes
	SCHEME_NUMBER=$(echo "$SCHEME_DESC_FILES" | wc -w)

	echo -e "View schemes: v\nChoose scheme: c\nQuit: q\n"
	read -p "Choice: " INPUT_0
	echo ""

	# If interrupt was chosen
	if [[ "$INPUT_0" == "q" ]]; then
		debug "SCRIPT '{PROJECT_ROOT}/partitioning/choose_scheme.sh' FINISHED EXECUTING (CODE: 1)"
		exit 1
	fi

	# If only enter was pressed
	if [[ "$INPUT_0" == "" ]]; then
		echo -e "Selected no option!\n"
		continue
	fi

	# If printing schemas was chosen
	if [[ "$INPUT_0" == "v" ]]; then

		while true; do

			echo -e "View all schemes: a\nView one scheme: 1-$SCHEME_NUMBER\nBack to main menu: q\n"
			read -p "Choice: " INPUT_1
			echo ""

			# if returning to main menu was chosen
			if [[ "$INPUT_1" == "q" ]]; then
				break
			fi

			# If only enter was pressed
			if [[ "$INPUT_1" == "" ]]; then
				continue
			fi

			# If viewing all schemas was chosen
			if [[ "$INPUT_1" == "a" ]]; then

				while true; do

					echo -e "Short description: s\nLong description: l\nBack to menu: q\n"
					read -p "Choice: " INPUT_2
					echo ""

					# If returning to menu was chosen
					if [[ "$INPUT_2" == "q" ]]; then
						break
					fi

					# If only enter was pressed
					if [[ "$INPUT_2" == "" ]]; then
						continue
					fi

					# If viewing schemas short info was chosen
					if [[ "$INPUT_2" == "s" ]]; then

						echo -e "Available scheme short descriptions:"

						echo -e "\n***********************************************************\n"
						COUNTER=1
						for INDEX in $SCHEME_DESC_FILES; do

							FIRST_LINE=$(head -n 1 "$WORK_DIR/partitioning/schemes/$PARTITIONING_STYLE/descriptions/$INDEX")
							echo "["$COUNTER"] $FIRST_LINE"
							((COUNTER++))

						done
						echo -e "\n***********************************************************\n"

					fi

					# If viewing schemas long info was chosen
					if [[ "$INPUT_2" == "l" ]]; then

						echo -e "Available scheme descriptions:"
						COUNTER=1
						for INDEX in $SCHEME_DESC_FILES; do

							echo -e "\n["$COUNTER"]********************************************************\n"
							while IFS= read -r LINE; do
								echo "$LINE"
							done < $WORK_DIR/partitioning/schemes/$PARTITIONING_STYLE/descriptions/$INDEX
							((COUNTER++))

						done
						echo -e "\n***********************************************************\n"

					fi

				done

			fi

			# If viewing one scheme was chosen
			if is_valid_number "$INPUT_1" "$SCHEME_NUMBER"; then
			
				while true; do

					echo -e "Short description: s\nLong description: l\nBack to menu: q\n"
					read -p "Choice: " INPUT_3
					echo ""

					# If returning to menu was chosen
					if [[ "$INPUT_3" == "q" ]]; then
						break
					fi

					# If only enter was pressed
					if [[ "$INPUT_3" == "" ]]; then
						continue
					fi

					# If viewing a schema short info was chosen
					if [[ "$INPUT_3" == "s" ]]; then

						echo -e "Selected scheme description:"
						echo -e "\n***********************************************************\n"
						FIRST_LINE=$(head -n 1 "$WORK_DIR/partitioning/schemes/$PARTITIONING_STYLE/descriptions/scheme_$INPUT_1.txt")
						echo "["$INPUT_1"] $FIRST_LINE"
						echo -e "\n***********************************************************\n"

					fi

					# If viewing a schema long info was chosen
					if [[ "$INPUT_3" == "l" ]]; then

						echo -e "Selected scheme description:"
						echo -e "\n["$INPUT_1"]********************************************************\n"
						while IFS= read -r LINE; do
							echo "$LINE"
						done < $WORK_DIR/partitioning/schemes/$PARTITIONING_STYLE/descriptions/scheme_$INPUT_1.txt
						echo -e "\n***********************************************************\n"

					fi
				
				done

			fi

		done

	fi

	# If choosing schema was chosen
	if [[ "$INPUT_0" == "c" ]]; then

		while true; do

			echo -e "Choose one scheme: 1-$SCHEME_NUMBER\nBack to main menu: q\n"
			read -p "Choice: " INPUT_4
			echo ""

			# if returning to main menu was chosen
			if [[ "$INPUT_4" == "q" ]]; then
				break
			fi

			# If only enter was pressed
			if [[ "$INPUT_4" == "" ]]; then
				continue
			fi

			# If valid disk was chosen
			if is_valid_number "$INPUT_4" "$SCHEME_NUMBER"; then
				FIRST_LINE=$(head -n 1 "$WORK_DIR/partitioning/schemes/$PARTITIONING_STYLE/descriptions/scheme_$INPUT_4.txt")
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
