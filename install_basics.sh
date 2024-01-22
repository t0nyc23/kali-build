#!/bin/bash
source utils_and_vars.sh

install_basic_utils(){
	print_header "Basic Software and Utilities."
	local logfile="$LOG_DIR/install_basic_utils.log"
	local software=(
		'net-tools' 'tmux' 'vim' 'htop' 'git'
		'flameshot' 'wget' 'vlc' 'curl' 'zip'
		'xcape' 'prips' 'xdotool' 'dnsutils'
		'gdebi' 'gparted' 'cherrytree'
		'linux-headers-amd64' 'wmctrl' 'peek'
		'lightdm-gtk-greeter-settings' 'xfce4-terminal' 'plocate'
		'libxfce4ui-2-dev' 'python3-psutil' 'make' 'gettext' 'intltool'
	)
	print_status "Doing an update."
	sudo apt-get update >> $logfile
	for package in "${software[@]}";do
		print_status "Installing: $package"
		sudo apt-get -y install $package >> $logfile
	done
	print_status "Done installing basic utilities/software."
}

install_panel_profiles(){
	local logfile="$LOG_DIR/xfce4-panel-profiles.log"
	print_header "Installing xfce4-panel-profiles"
	git clone "https://gitlab.xfce.org/apps/xfce4-panel-profiles.git"
	cd "xfce4-panel-profiles"
	print_status "Running: sh configure"
	sh configure >> $logfile
	print_status "Running: make"
	make >> $logfile
	print_status "Running: sudo make install"
	sudo make install >> $logfile
	cd ..
}

install_protonvpn(){
	local logfile="$LOG_DIR/install_protonvpn.log"
	local pvpnurl="https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3_all.deb"
	local pvpndeb=`echo $pvpnurl | awk -F '/' '{print $9}'`
	print_header "Proton VPN Setup (CLI)"
	print_status "Installing ${pvpndeb}"
	wget -q $pvpnurl && sudo gdebi -n $pvpndeb
	print_status "Doing and update."
	sudo apt-get update >> $logfile
	print_status "Installing protonvpn-cli"
	sudo apt-get -y install protonvpn-cli >> $logfile
	rm $pvpndeb
	print_status "Finished setup for Proton VPN"
}

install_veracrypt(){
	#Add the following to Default mount parameters (mount options):
	#	fmask=133,dmask=022
	local logfile="$LOG_DIR/install_veracrypt.log"
	local vcurl="https://launchpad.net/veracrypt/trunk/1.26.7/+download/veracrypt-1.26.7-Debian-12-amd64.deb"
	local vcdeb=`echo $vcurl | awk -F '/' '{print $8}'`
	print_header "Setting Up Veracrypt"
	print_status "Installing $vcdeb"
	wget -q $vcurl
	sudo gdebi -n $vcdeb >> $logfile
	print_status "Finished installing Veracrypt"
	rm $vcdeb
}

install_obsidian(){
	local logfile="$LOG_DIR/install_obsidian.log"
	local oburl="https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.3/obsidian_1.5.3_amd64.deb"
	local obdeb=`echo $oburl | awk -F '/' '{print $9}'`
	print_header "Obsidian Installation"
	print_status "Downloading and installing Obsidian"
	wget -q $oburl
	sudo gdebi -n $obdeb >> $logfile
	print_status "Finished installing Obsidian"
	rm $obdeb
}

install_brave(){
	local logfile="$LOG_DIR/install_brave.log"
	local brgpg="/usr/share/keyrings/brave-browser-archive-keyring.gpg"
	local brurl="https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
	print_header "Setting Up Brave Browser"
	print_status "Import GPG from ${brurl}"
	sudo curl -fsSLo $brgpg $brurl
	print_status "Adding Brave Browser's repo."
	echo "deb [signed-by=${brgpg}] https://brave-browser-apt-release.s3.brave.com/ stable main"| \
		sudo tee /etc/apt/sources.list.d/brave-browser-release.list >> $logfile
	print_status "Doing an update."
	sudo apt-get update >> $logfile
	print_status "Installing Brave Browser"
	sudo apt-get -y install brave-browser >> $logfile
	print_status "Brave is now installed"
}

install_sublime(){
	local logfile="$LOG_DIR/install_sublime.log"
	local suburl="https://download.sublimetext.com/sublimehq-pub.gpg"
	print_header "Setting Up Sublime Text"
	print_status "Importing GPG from $suburl"
	wget -qO - $suburl | gpg --dearmor | sudo tee \
		/etc/apt/trusted.gpg.d/sublimehq-archive.gpg >> $logfile
	print_status "Adding Sublime's Repository"
	echo "deb https://download.sublimetext.com/ apt/stable/" | \
		sudo tee /etc/apt/sources.list.d/sublime-text.list >> $logfile
	print_status "Doing an update."
	sudo apt-get update >> $logfile
	print_status "Installing Sublime Text"
	sudo apt-get -y install sublime-text >> $logfile
	print_status "Sublime-Text is now installed."
}
