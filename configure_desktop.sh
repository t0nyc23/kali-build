#!/bin/bash

source utils_and_vars.sh

install_themes(){
	local themes_dest="/usr/share/themes/"
	local icons_dest="/usr/share/icons/"
	local theme_link="https://gitlab.com/kalilinux/packages/gnome-theme-kali/-/archive/kali/master/gnome-theme-kali-kali-master.zip"

	local bg_link="https://gitlab.com/kalilinux/packages/kali-wallpapers/-/raw/kali/master/legacy/backgrounds/kali-1.1/kali-1.1-2560x1440.png?ref_type=heads"
	local bg_dest="/usr/share/backgrounds/kali-16x9/kali-old.png"
	local bg_default="/usr/share/backgrounds/kali-16x9/default"


	print_header " Installing and configuring themes."
	mkdir tmp && cd tmp
	print_status "Downloading theme zip archive."
	wget -qO "theme.zip" $theme_link
	print_status "Extracting theme zip archive."
	unzip -q "theme.zip" 

	local theme_src="gnome-theme-kali-kali-master/GTK-And-GnomeShell-Theme/*"
	local icons_src="gnome-theme-kali-kali-master/Icon-Theme/*"
	print_status "Copying Theme to $themes_dest"
	sudo cp -r $theme_src $themes_dest
	print_status "Copying Icons to $icons_dest"
	sudo cp -r $icons_src $icons_dest

	print_status "Downloading default background wallpaper."
	wget -qO "kali-old.png" $bg_link
	print_status "Moving wallpaper to $bg_dest"
	sudo cp "kali-old.png" $bg_dest
	print_status "Creating link for $bg_dest"
	sudo ln -sf $bg_dest $bg_default


	print_status "Cleaning up."
	cd .. && rm -rf tmp

}

configure_xfce4_desktop(){	
	local dest_xfce_conf="$HOME/.config/xfce4"
	local src_xfce_conf="$CONFIG_DIR/xfce4/*"
	local panel_config="$FILES_DIR/kali-custom-panel.tar.bz2"
	local lightdm_dest="/etc/lightdm/"
	local lightdm_src="$FILES_DIR/lightdm-gtk-greeter.conf"
	
	print_header "Configuring XFCE4 desktop environment."
	print_status "Importing XFCE4 settings."
	cp -r $src_xfce_conf $dest_xfce_conf
	
	print_status "Applying themes."
	xfconf-query -c xfwm4 -p /general/theme -s Kali-X
	xfconf-query -c xsettings -p /Net/ThemeName -s Kali-X
	xfconf-query -c xsettings -p /Net/IconThemeName -s Vibrancy-Kali-Full-Dark

	print_status "Importing custom panel configuration."
	xfce4-panel-profiles load $panel_config
	
	print_status "Installing LightDM greeter configuration."
	sudo cp $lightdm_src $lightdm_dest

	print_status "Make xfce4-terminal the default terminal emulator."
	sudo update-alternatives --set x-terminal-emulator "/usr/bin/xfce4-terminal.wrapper"
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

configure_bashrc(){
	local bashrc_file="$FILES_DIR/BASHRC"
	local me=$USER
	print_header "Configuring user shells"
	print_status "Configuring shell for $me"
	sudo chsh -s /usr/bin/bash $me
	print_status "Configuring shell for root"
	sudo chsh -s /usr/bin/bash $USER
	print_status "Copying $bashrc_file for $USER"
	cp $bashrc_file $HOME/.bashrc
	print_status "Copying $bashrc_file for root"
	sudo cp $bashrc_file $HOME/.bashrc
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