#!/bin/bash
CRESET="\e[0m"
RED="\e[1;31m"
CYAN="\e[1;34m"

LOG_DIR="$HOME/Desktop/build/"
LOG_OUT="$HOME/Desktop/build.log"

FILES_DIR="$PWD/files"
CONFIG_DIR="$FILES_DIR/dot_config"

print_status(){
	local message=$1
	echo -e "${CYAN}--- $message${CRESET}" | tee -a $LOG_OUT
}

print_header(){
	local message=$1
	local formated="${CYAN}
	\r==============================================================\n
	\r[+] $message\n
	\r==============================================================${CRESET}"
	echo -e $formated |tee -a $LOG_OUT
}

print_error(){
	local message=$1
	local formated="${RED}
	\r==============================================================\n
	\r[!] $message\n
	\r==============================================================${CRESET}"
	echo -e $formated |tee -a $LOG_OUT
}