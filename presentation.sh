#!/bin/bash

# EXPLICAR MAS EN DETALLE LAS HERRAMIENTAS
# HACER 'PDF' DE LA INSTALACIÓN DE LA HERRAMIENTA
# HACER DEMO EN PROXMOX
# HACER UNA ACTIVIDAD PARA QUE LA CLASE LA HAGA ( INCLUIR INSTALACIÓN )

# 1. PORTADA				  
# 2. INDICE					  
# 3. QUE ES Y COMO SE UTILIZA 
# 4. EJEMPLOS				  

QUIT=0
SLIDE_COUNT=0
#TRANS_TIME=20
TRANS_TIME=0
WIDTH=$(stty size | cut -d " " -f 2)
HEIGHT=$(stty size | cut -d " " -f 1)

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

movem () {
	local OPTIND
	while getopts ":u:d:f:b:c:" opt; do
		case $opt in
			"u") echo -n -e "\e[${OPTARG}A"    ;;
			"d") echo -n -e "\e[${OPTARG}B"    ;;
			"f") echo -n -e "\e[${OPTARG}C"    ;;
			"b") echo -n -e "\e[${OPTARG}D"    ;;
			"c")
				# movem -c X-Y
				X_AXI=$(echo -n "${OPTARG}" | cut -d "-" -f 1)
				Y_AXI=$(echo -n "${OPTARG}" | cut -d "-" -f 2)
				TEXT_MV="\e[${Y_AXI};${X_AXI};H"
				echo -n -e $TEXT_MV
			;;
			*) continue ;;
		esac
	done
}

if [[ $(whoami) != "root" ]]; then
	logm "l" "Run as root"
fi

# CLEAR && HIDE MOUSE
clear
tput civis

wrap_text () {

	movem -c "$1-$2"

	LENGTH=$3
	TEXT=$4
	COUNT=0

	for (( x=0; x<${#TEXT}; x++ )); do
		if [[ $LENGTH == $COUNT ]]; then
			movem -d 1 -b $LENGTH 
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

	movem -c "$1-$2"

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
			movem -d 1 -b $COUNT_BCK
			echo -n -e ${TEXT:$x:1}
			COUNT=0
			COUNT_BCK=0
		else
			echo -n -e ${TEXT:$x:1}
		fi

	done
}

largest_line () {
	LINE=$( bash -c "$1" | head -n 4 | tr '\n' '*' )
	LARGEST=0
	COUNT=0

	for (( char=0; char < ${#LINE}; char++)); do
		if [[ ${LINE:$char:1} == "*" ]]; then
			if [[ $COUNT > $LARGEST ]]; then
				LARGEST=$COUNT
			fi
			COUNT=0
		else
			((COUNT++))
		fi
	done

	return $LARGEST
}

# show_table X Y COMMAND
show_table () {
	BACK=0
	CMD=$(bash -c "$3" | head -n 10 | tr '	' ' ' | tr '\n' '*')
	largest_line $3
	CMD_X=$(($1 - ( $? / 2 ) ))
	movem -c "$CMD_X-$2"

	for (( char=0; char < ${#CMD}; char++)); do
		if [[ ${CMD:$char:1} == "*" ]]; then
			movem -b $BACK -d 1
			BACK=0
		else
			echo -n "${CMD:$char:1}"
			((BACK++))
		fi
	done
}

echo_text () {
	movem -c "$1-$2"
	echo -n -e $3
}

transition () {
	movem -c "0-0"
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

	movem -c "0-0"
	for y in $( seq 1 $HEIGHT); do
		for x in $( seq 1 $WIDTH); do
			echo -n " "
			for (( x=0; x<$TRANS_TIME; x++)); do
				continue
			done
		done
	done
}

mockup_slide () {
	TEXT="Press J to begin"
	echo_text $((WIDTH / 2 - ( ${#TEXT} / 2))) $((HEIGHT / 2)) "$TEXT"
}

slide_n1 () {
	FIRST_TEXT="Daniel Lopez"
	SECOND_TEXT="|||||||||||||||"
	THIRD_TEXT="Presentacion ASO SYSSTAT"
	wrap_textbw $((WIDTH / 2 - 10)) $((HEIGHT / 2 + 1)) 1 "$FIRST_TEXT"
	wrap_text $((WIDTH / 2)) $(((HEIGHT / 2) + 1 - (${#SECOND_TEXT} / 2))) 1 "$SECOND_TEXT"
	wrap_textbw $((( WIDTH / 2 ) + 5 )) $((HEIGHT / 2 - 1)) 2 "$THIRD_TEXT"
}

slide_n2 () {
	FIRST_TEXT="INDICE - SYSSTAT LINUX"
	echo_text 15 5 "$FIRST_TEXT"
}

slide_n3 () {
	FIRST_TEXT="SYSSTAT - QUÉ ES Y COMO SE UTILIZA"
	SECOND_TEXT="Sysstat es una 'suit' o conjunto de herramientas las cuales se utilizan para la monitorización de un sistema Linux. Este se encuentra facilmente instalable en todas las distribuciones actualizadas de Linux."
	THIRD_TEXT="Dentro de esta 'suit' se encuentran las siguientes herramientas:"
	FOURTH_TEXT="MPSTAT: Herramienta para monitorización de los recursos"
	FIFTH_TEXT="PIDSTAT: Herramienta para monitorización de los procesos"
	SIXTH_TEXT="IOSTAT: Herramienta para monitorización de los usuarios"
	echo_text 15 5 "$FIRST_TEXT"
	wrap_textbw 15 10 7 "$SECOND_TEXT"
	wrap_textbw 15 17 9 "$THIRD_TEXT"
	wrap_textbw 15 19 2 "$FOURTH_TEXT"
	wrap_textbw 45 19 2 "$FIFTH_TEXT"
	wrap_textbw 75 19 2 "$SIXTH_TEXT"
}

slide_n4 () {
	FIRST_TEXT="SYSSTAT - MPSTAT"
	SECOND_TEXT="Esta herramienta..."
	echo_text 15 5 "$FIRST_TEXT"
	wrap_textbw 15 10 10 "$SECOND_TEXT"
	show_table $(($WIDTH / 2)) $(($HEIGHT - 10)) "mpstat"
}

slide_n5 () {
	FIRST_TEXT="SYSSTAT - PIDSTAT"
	SECOND_TEXT="Esta herramienta..."
	echo_text 15 5 "$FIRST_TEXT"
	wrap_textbw 15 10 10 "$SECOND_TEXT"
	show_table $(($WIDTH / 2 - 9)) $(($HEIGHT - 10)) "pidstat"
}

slide_n6 () {
	FIRST_TEXT="SYSSTAT - IOSTAT"
	SECOND_TEXT="Esta herramienta..."
	echo_text 15 5 "$FIRST_TEXT"
	wrap_textbw 15 10 10 "$SECOND_TEXT"
	show_table $(($WIDTH / 2 - 15)) $(($HEIGHT - 10)) "iostat"
}

mockup_slide

while [[ $QUIT != 1 ]]; do
	read -sn1 CHOICE
	
	case $CHOICE in
		"q") clear; tput cnorm; exit ;;
		"j") 
			clear
			((SLIDE_COUNT++))
			transition
		;;
		"k") 
			clear
			if [[ $SLIDE_COUNT > 1 ]]; then
				((SLIDE_COUNT--))
				transition
			fi
		;;
	esac

	case $SLIDE_COUNT in
		1) slide_n1 ;;
		2) slide_n2 ;;
		3) slide_n3 ;;
		4) slide_n4 ;;
		5) slide_n5 ;;
		6) slide_n6 ;;
	esac
done
