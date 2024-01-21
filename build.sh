#!/bin/bash
source utils_and_vars.sh
source configure_desktop.sh
source install_basics.sh

print_header "Creating $LOG_DIR and $LOG_OUT"
mkdir -p $LOG_DIR
if [ $? -eq 0 ];then
	print_status "Starting build scripts."
else
	print_error "Something went wrong."
	exit
fi

#[INSTALL BASICS]
#-------------------------------------
basics_cmds=(
'configure_repos'
'install_basic_utils'
'install_nvidia_drivers'
'install_virtualbox'
'install_snap_tools'
'install_protonvpn'
'install_veracrypt'
'install_obsidian'
'install_discord_plus'
'install_brave'
'install_sublime'
)

print_header "Installing Software and Utilities."
for task in "${basics_cmds[@]}";do
	$task
	if [ $? -eq 0 ];then
		print_status "Finished with task: $task"
	fi
done

#[CONFIGURE DESKTOP]
#-------------------------------------
config_cmds=(
	'install_themes'
	'configure_xfce4_desktop'
	'configure_move2screen'
	'configure_super_key'
	'configure_bashrc'
	'configure_tmux'
	'configure_sublime'
)
print_header "Making Desktop Configurations."
for task in "${config_cmds[@]}";do
	$task
	if [ $? -eq 0 ];then
		print_status "Finished with task: $task"
	fi
done