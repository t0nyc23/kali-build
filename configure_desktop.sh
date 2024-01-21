#!/bin/bash

source utils_and_vars.sh

install_themes(){
	local themes_dest="/usr/share/themes/"
	local icons_dest="/usr/share/icons/"
	local bg_dest="/usr/share/backgrounds/"
	local bg_default="/usr/share/images/desktop-base/default"
	local lightdm_dest="/etc/lightdm/"
	local git_repo="https://github.com/t0nyc23/non-themes"

	print_header "Installing and configuring themes."
	print_status "Cloning $git_repo"
	git clone -q $git_repo
	cd non-themes
	
	print_status "Installing non-gtk-dark theme."
	sudo cp -r non-gtk-dark $themes_dest
	print_status "Installing non-gtk-darker theme."
	sudo cp -r non-gtk-darker $themes_dest
	print_status "Installing non-blue-icons theme."
	sudo cp -r non-blue-icons $icons_dest
	print_status "Installing LightDM greeter configuration."
	sudo cp lightdm-gtk-greeter.conf $lightdm_dest
	print_status "Adding background.jpg to /usr/share/backgrounds."
	sudo cp background.jpg $bg_dest
	print_status "Creating symlink for backround.jpg"
	sudo ln -sf $bg_dest/background.jpg $bg_default
}


configure_xfce4_desktop(){	
	local dest_xfce_conf="$HOME/.config/xfce4"
	local src_xfce_conf="$CONFIG_DIR/xfce4/*"
	local panel_config="$FILES_DIR/non-custom-panel.tar.bz2"
	
	print_header "Configuring XFCE4 desktop environment."
	print_status "Importing XFCE4 settings."
	cp -r $src_xfce_conf $dest_xfce_conf
	
	print_status "Applying themes."
	xfconf-query -c xfwm4 -p /general/theme -s non-gtk-dark
	xfconf-query -c xsettings -p /Net/ThemeName -s non-gtk-dark
	xfconf-query -c xsettings -p /Net/IconThemeName -s non-blue-icons

	print_status "Importing custom panel configuration."
	xfce4-panel-profiles load $panel_config
}

configure_move2screen(){
	local script_file="$FILES_DIR/move2screen"
	local install_dir="/usr/local/bin/move2screen"
	print_header "Configuring move2screen"
	sudo cp $script_file $install_dir
	if [ $? -eq 0 ];then
		sudo chown root:root $install_dir
		sudo chmod 755 $install_dir
		print_status "Done"
	else
		print_error "Failed to configure move2screen"
	fi
}

configure_super_key(){
	local autostart_dir="$CONFIG_DIR/autostart"
	print_header "Configuring Super Key to open Menu"
	cp -r $autostart_dir "$HOME/.config"
	if [ $? -eq 0 ];then
		print_status "All ok"
	else
		print_error "Failed to configure super key menu"
	fi
}

configure_bashrc(){
	local bashrc_file="$FILES_DIR/BASHRC"
	print_header "Configuring .bashrc"
	cp $bashrc_file $HOME/.bashrc
}

configure_tmux(){
	local tmux_file="$FILES_DIR/TMUX_CONF"
	print_header "Configuring .tmux.conf"
	cp $tmux_file $HOME/.tmux.conf
}

configure_sublime(){
	local config_dir="$CONFIG_DIR/sublime-text/*"
	local dest="$HOME/.config/sublime-text/"
	print_header "Configuring Sublime Text"
	mkdir -p $dest
	cp -r $config_dir $dest
	if [ $? -eq 0 ];then
		print_status "All ok"
	else
		print_error "Failed to configure LightDM"
	fi	
}