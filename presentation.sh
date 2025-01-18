#!/bin/bash

WIDTH=$(stty size | cut -d " " -f 2)
HEIGHT=$(stty size | cut -d " " -f 1)
TRANS_TIME=100

ESC_END="\e[0m"
CLR_RED="\e[31m"
CLR_BLUE="\e[34m"
CLR_GREEN="\e[32m"
CLR_YELLOW="\e[33m"

logm () {
	case $1 in
		"n") echo "$(date +%D\ %T) | $2" ;;
		"l") echo -e "$CLR_BLUE$(date +%D\ %T) | $2$ESC_END" ;;
		"m") echo -e "$CLR_YELLOW$(date +%D\ %T) | $2$ESC_END" ;;
		"c") echo -e "$CLR_RED$(date +%D\ %T) | $2$ESC_END" ;;
	esac
	return 0
}

moveu () { echo -e -n "\e[$1A"; }
moved () { echo -e -n "\e[$1B"; }
mover () { echo -e -n "\e[$1C"; }
movel () { echo -e -n "\e[$1D"; }
movec () { echo -e -n "\e[$1;$2H"; }

if [[ $(whoami) != "root" ]]; then
	logm "l" "Run as root"
else
	if [ $WIDTH -lt 80 ] || [ $HEIGHT -lt 40 ]; then
		logm "m" "Script can´t run on actual terminal size"
	fi
fi

# CLEAR
clear

wrap_text () {

	movec $2 $1

	LENGTH=$3
	TEXT=$4
	COUNT=0

	for (( x=0; x<${#TEXT}; x++ )); do
		if [[ $LENGTH == $COUNT ]]; then
			moved 1
			movel $LENGTH
			echo -n -e ${TEXT:$x:1}
			COUNT=0
		else
			echo -n -e ${TEXT:$x:1}
		fi

		((COUNT++))
	done
}

# wrap-text(By)(Word)
# wrap_textbw X Y LENGTH TEXT
wrap_textbw () {

	movec $2 $1

	LENGTH=$3
	TEXT=$4
	COUNT=0
	COUNT_BCK=0

	for (( x=0; x<${#TEXT}; x++ )); do

		if [[ ${TEXT:$x:1} == " " ]]; then
			echo -n " " 
			((COUNT++))
		fi

		((COUNT_BCK++))

		if [[ $LENGTH == $COUNT ]]; then
			moved 1
			movel $COUNT_BCK
			echo -n -e ${TEXT:$x:1}
			COUNT=0
			COUNT_BCK=0
		else
			echo -n -e ${TEXT:$x:1}
		fi

	done
}

echo_text () {
	movec $2 $1
	echo -n -e $3
}

transition () {
	movec 0 0
	BT=0
	for y in $( seq 1 $HEIGHT); do
		for x in $( seq 1 $WIDTH); do
			if [ $BT -eq 0 ]; then
				echo -n -e "\033[48;5;255m \033[0m"
				BT=1
			else
				echo -n " "
				BT=0
			fi
			for (( x=0; x<$TRANS_TIME; x++)); do
				continue
			done
		done
	done

	movec 0 0
	for y in $( seq 1 $HEIGHT); do
		for x in $( seq 1 $WIDTH); do
			echo -n " "
			for (( x=0; x<$TRANS_TIME; x++)); do
				continue
			done
		done
	done
}

first_slide () {
	FIRST_TEXT="Daniel Lopez"
	SECOND_TEXT="|||||||||||||||"
	THIRD_TEXT="Presentacion ASO SYSSTAT"
	wrap_textbw $((WIDTH / 2 - 10)) $((HEIGHT / 2 + 1)) 1 "$FIRST_TEXT"
	wrap_text $((WIDTH / 2)) $(((HEIGHT / 2) + 1 - (${#SECOND_TEXT} / 2))) 1 "$SECOND_TEXT"
	wrap_textbw $((( WIDTH / 2 ) + 5 )) $((HEIGHT / 2 - 1)) 2 "$THIRD_TEXT"
}
