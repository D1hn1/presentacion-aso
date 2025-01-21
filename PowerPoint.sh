#!/bin/bash

QUIT=0
SLIDES=8
CHOICE="j"
SLIDE_COUNT=0

TRANS_TIME=20    # YOU CAN CHANGE THIS
TRANS_ENABLED=1  # YOU CAN CHANGE THIS

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

if [[ $WIDTH > 119 ]]; then 
	if [ ! mpstat &>/dev/null ]; then
		logm "c" "Sysstat is not installed"
		exit
	fi
else
	logm "m" "Script can´t run on actual terminal size"
	exit
fi

# CLEAR && HIDE MOUSE
clear
tput civis

# movem -u UP -d DOWN ...
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

# wrap_text X Y LENGTH TEXT
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
	LINE=$( bash -c "$1" | head -n 4 | tr '	' ' ' | tr '\n' '*' )
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

# echo_text X Y TEXT
echo_text () {
	movem -c "$1-$2"
	echo -n -e $3
}

transition () {
	movem -c "0-0"
	BT=0
	for y in $( seq 1 $HEIGHT); do

		if [[ $(($WIDTH % 2)) == 0 ]]; then
			if [[ $BT == 0 ]]; then 
				BT=1
			else 
				BT=0 
			fi
		fi

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

# draw_number NUMBER
draw_number () {
	movem -c "3-2"
	echo -n "$1 |"
}

slide_n1 () {
	draw_number 1
	FIRST_TEXT="Daniel Lopez"
	SECOND_TEXT="|||||||||||||||"
	THIRD_TEXT="Presentacion ASO SYSSTAT"
	wrap_textbw $((WIDTH / 2 - 10)) $((HEIGHT / 2 + 1)) 1 "$FIRST_TEXT"
	wrap_text $((WIDTH / 2)) $(((HEIGHT / 2) + 1 - (${#SECOND_TEXT} / 2))) 1 "$SECOND_TEXT"
	wrap_textbw $((( WIDTH / 2 ) + 5 )) $((HEIGHT / 2 - 1)) 2 "$THIRD_TEXT"
}

slide_n2 () {
	draw_number 2
	FIRST_TEXT="INDICE - SYSSTAT LINUX"
	SECOND_TEXT="1. Introducción"
	THIRD_TEXT="2. Indice"
	FOURTH_TEXT="3. Qué es y para que se utiliza"
	FIFTH_TEXT="4. MPSTAT"
	SIXTH_TEXT="5. PIDSTAT"
	SEVENTH_TEXT="6. IOSTAT"
	EIGTH_TEXT="7. Sysstat demonio"
	NINETH_TEXT="8. Fin"
	echo_text 15 5 "$FIRST_TEXT"
	echo_text 15 10 "$SECOND_TEXT"
	echo_text 15 11 "$THIRD_TEXT"
	echo_text 15 12 "$FOURTH_TEXT"
	echo_text 18 13 "$FIFTH_TEXT"
	echo_text 18 14 "$SIXTH_TEXT"
	echo_text 18 15 "$SEVENTH_TEXT"
	echo_text 15 16 "$EIGTH_TEXT"
	echo_text 15 17 "$NINETH_TEXT"
}

slide_n3 () {
	draw_number 3
	FIRST_TEXT="SYSSTAT - QUÉ ES Y PARA QUE SE UTILIZA"
	SECOND_TEXT="Sysstat es una 'suit' o conjunto de herramientas las cuales se utilizan para la monitorización de un sistema Linux. Este se encuentra facilmente instalable en todas las distribuciones actualizadas de Linux."
	THIRD_TEXT="Dentro de esta 'suit' se encuentran las siguientes herramientas:"
	FOURTH_TEXT="MPSTAT: Herramienta para monitorización de los recursos."
	FIFTH_TEXT="PIDSTAT: Herramienta para monitorización de los procesos."
	SIXTH_TEXT="IOSTAT: Herramienta para monitorización de los usuarios."
	echo_text 15 5 "$FIRST_TEXT"
	wrap_textbw 15 10 7 "$SECOND_TEXT"
	wrap_textbw 15 17 9 "$THIRD_TEXT"
	wrap_textbw 15 19 2 "$FOURTH_TEXT"
	wrap_textbw 45 19 2 "$FIFTH_TEXT"
	wrap_textbw 75 19 2 "$SIXTH_TEXT"
}

slide_n4 () {
	draw_number 4
	FIRST_TEXT="SYSSTAT - MPSTAT"
	SECOND_TEXT="Con la herramienta MPSTAT podremos ver el uso de los núcleos de la CPU. Para ello podremos utilizar la aplicación sin ningún argumento."
	THIRD_TEXT="Al comando se le pueden pasar dos valores, eston son los intervalos y el tiempo (mpstat 2 1) en este ejemplo hará 1 intervalo de 2 segundos."
	FOURTH_TEXT="ARGUMENTOS : -A: ALL -o: JSON"
	echo_text 15 5 "$FIRST_TEXT"
	wrap_textbw 15 10 7 "$SECOND_TEXT"
	wrap_textbw 15 15 7 "$THIRD_TEXT"
	wrap_textbw 80 10 2 "$FOURTH_TEXT"
	show_table $(($WIDTH / 2)) $(($HEIGHT - 10)) "mpstat"
}

slide_n5 () {
	draw_number 5
	FIRST_TEXT="SYSSTAT - PIDSTAT"
	SECOND_TEXT="Con la herramienta MPSTAT podremos ver el uso de los procesos en el sistema. Para ello podremos utilizar la aplicación sin ningún argumento."
	THIRD_TEXT="Al comando se le pueden pasar dos valores, eston son los intervalos y el tiempo (pidstat 2 1) en este ejemplo hará 1 intervalo de 2 segundos."
	FOURTH_TEXT="ARGUMENTOS:"
	FIFTH_TEXT="-C, -G: Muestra solo procesos con el nombre que indiques."
	SIXTH_TEXT="-p, -U: Muestra el proceso con el PID/usuario introducido."
	echo_text 15 5 "$FIRST_TEXT"
	wrap_textbw 15 10 7 "$SECOND_TEXT"
	wrap_textbw 15 15 7 "$THIRD_TEXT"
	wrap_textbw 80 10 1 "$FOURTH_TEXT"
	wrap_textbw 80 11 4 "$FIFTH_TEXT"
	wrap_textbw 80 14 4 "$SIXTH_TEXT"
	show_table $(($WIDTH / 2)) $(($HEIGHT - 10)) "pidstat"
}

slide_n6 () {
	draw_number 6
	FIRST_TEXT="SYSSTAT - IOSTAT"
	SECOND_TEXT="Con la herramienta IOSTAT podremos ver tanto el uso de la CPU como el del disco duro. Para ello podremos utilizar la aplicación sin ningún argumento."
	THIRD_TEXT="Al comando se le pueden pasar dos valores, eston son el tiempo y los intervalos (iostat 2 1) en este ejemplo hará 2 intervalo de 1 segundos."
	FOURTH_TEXT="ARGUMENTOS:"
	FIFTH_TEXT="-h: Muestra el output de una manera más bonita y ordenada."
	SIXTH_TEXT="-o: Muestra el output en JSON." 
	echo_text 15 5 "$FIRST_TEXT"
	wrap_textbw 15 10 7 "$SECOND_TEXT"
	wrap_textbw 15 15 7 "$THIRD_TEXT"
	wrap_textbw 80 10 1 "$FOURTH_TEXT"
	wrap_textbw 80 11 4 "$FIFTH_TEXT"
	wrap_textbw 80 14 4 "$SIXTH_TEXT"
	show_table $(($WIDTH / 2 - 13)) $(($HEIGHT - 10)) "iostat"
}

slide_n7 () {
	draw_number 7
	FIRST_TEXT="SYSSTAT - DEMONIO"
	SECOND_TEXT="La suit de Sysstat también cuenta con un demonio el cual se puede activar mediante systemctl."
	THIRD_TEXT="El comando será el siguiente: systemctl start sysstat.service."
	FOURTH_TEXT="Una vez activo sysstat guardará los 'logs' en la carpeta /var/log/sysstat."
	FIFTH_TEXT="root@linux~# ls /var/log/sysstat"
	SIXTH_TEXT="sa01 sa02 sa03 sa04 sa05 sa06 sa07 sa08 sa09 sa10 sa11 sa12 sa13 sa14 sa15 sa16 sa17 sa18 sa19 sa20 sa21 sa22 sa23 sa24 sa25 sa26 sa27 sa29 sa30 sa31"
	echo_text 15 5 "$FIRST_TEXT"
	wrap_textbw 15 10 7 "$SECOND_TEXT"
	wrap_textbw 15 14 10 "$THIRD_TEXT"
	wrap_textbw 15 16 7 "$FOURTH_TEXT"
	wrap_textbw 15 19 10 "$FIFTH_TEXT"
	wrap_textbw 15 21 15 "$SIXTH_TEXT"
}

slide_n8 () {
	IFS='%'
	BANNER_A="#######  ####  ##    ##" # 3
	BANNER_B="#######  ####  ##    ##" # 2
	BANNER_C="###      ####  ####  ##" # 1
	BANNER_D="######   ####  ####  ##" # 0
	BANNER_E="###      ####  ##  ####" # 1
	BANNER_F="###      ####  ##  ####" # 2
	BANNER_G="###      ####  ##    ##" # 3
	echo_text $(($WIDTH / 2 - ( 23 / 2))) $(($HEIGHT / 2 - 3)) "$BANNER_A"
	echo_text $(($WIDTH / 2 - ( 23 / 2))) $(($HEIGHT / 2 - 2)) "$BANNER_B"
	echo_text $(($WIDTH / 2 - ( 23 / 2))) $(($HEIGHT / 2 - 1)) "$BANNER_C"
	echo_text $(($WIDTH / 2 - ( 23 / 2))) $(($HEIGHT / 2)) "$BANNER_D"
	echo_text $(($WIDTH / 2 - ( 23 / 2))) $(($HEIGHT / 2 + 1)) "$BANNER_E"
	echo_text $(($WIDTH / 2 - ( 23 / 2))) $(($HEIGHT / 2 + 2)) "$BANNER_F"
	echo_text $(($WIDTH / 2 - ( 23 / 2))) $(($HEIGHT / 2 + 3)) "$BANNER_G"
	unset IFS
}

while [[ $QUIT != 1 ]]; do
	
	case $CHOICE in
		"q") clear; tput cnorm; exit ;;
		"j") 
			clear
			if [[ $SLIDE_COUNT < $SLIDES ]]; then
				((SLIDE_COUNT++))
				if [[ $TRANS_ENABLED == 1 ]]; then
					transition
				fi
			fi
		;;
		"k") 
			clear
			if [[ $SLIDE_COUNT > 1 ]]; then
				((SLIDE_COUNT--))
				if [[ $TRANS_ENABLED == 1 ]]; then
					transition
				fi
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
		7) slide_n7 ;;
		8) slide_n8 ;;
	esac

	read -sn1 CHOICE

done
