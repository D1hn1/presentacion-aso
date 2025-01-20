#!/bin/bash

# · Una presentación tipo "Power Point" / Prezi explicando:
# 	- Qué herramienta va a presentar
# 	- Características principales detalladas, desde el punto de vista de un Administrador de Sistemas
# 	- Ejemplo visual de cada característica
# · Un tutorial (pdf) que explique el proceso de instalación y uso general de la herramienta.
# · Demo en un sistema real (en PROXMOX) del uso de la herramienta
# · Preparación de una actividad a realizar por el resto del alumnado (práctica obligatoria) que incluya la instalación y algun/os usos  de dicha herramienta.

# EXPLICAR SAR COMO SERVICIO
# EXPLICAR MAS EN DETALLE LAS HERRAMIENTAS
# HACER 'PDF' DE LA INSTALACIÓN DE LA HERRAMIENTA
# HACER DEMO EN PROXMOX
# HACER UNA ACTIVIDAD PARA QUE LA CLASE LA HAGA ( INCLUIR INSTALACIÓN )

# 1. PORTADA				  
# 2. INDICE					  
# 3. QUE ES Y COMO SE UTILIZA 
# 4. EJEMPLOS				  

QUIT=0
SLIDES=6
CHOICE="j"
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

if [ ! mpstat &>/dev/null ]; then
	logm "c" "Sysstat is not installed"
	exit
fi

# CLEAR && HIDE MOUSE
clear
tput civis

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

draw_number () {
	movem -c "2-2"
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
	echo_text 15 5 "$FIRST_TEXT"
}

slide_n3 () {
	draw_number 3
	FIRST_TEXT="SYSSTAT - QUÉ ES Y COMO SE UTILIZA"
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
	SECOND_TEXT="Con la herramienta MPSTAT podremos ver tanto el uso de la CPU como el del disco duro. Para ello podremos utilizar la aplicación sin ningún argumento."
	THIRD_TEXT="Al comando se le pueden pasar dos valores, eston son el tiempo y los intervalos (iostat 2 1) en este ejemplo hará 2 intervalo de 1 segundos."
	FOURTH_TEXT="ARGUMENTOS:"
	echo_text 15 5 "$FIRST_TEXT"
	wrap_textbw 15 10 7 "$SECOND_TEXT"
	wrap_textbw 15 15 7 "$THIRD_TEXT"
	show_table $(($WIDTH / 2 - 13)) $(($HEIGHT - 10)) "iostat"
}

while [[ $QUIT != 1 ]]; do
	
	case $CHOICE in
		"q") clear; tput cnorm; exit ;;
		"j") 
			clear
			if [[ $SLIDE_COUNT < $SLIDES ]]; then
				((SLIDE_COUNT++))
				transition
			fi
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

	read -sn1 CHOICE

done
