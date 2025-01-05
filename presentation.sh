#!/bin/bash

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


