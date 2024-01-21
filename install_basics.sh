#!/bin/bash
source utils_and_vars.sh

install_basic_utils(){
	print_header "Basic Software and Utilities."
	local logfile="$LOG_DIR/install_basic_utils.log"
	local software=(
		'net-tools' 'tmux' 'vim' 'htop' 'git'
		'flameshot' 'wget' 'vlc' 'curl' 'zip'
		'xcape' 'prips' 'xdotool' 'dnsutils'
		'piper' 'gdebi' 'gparted' 'cherrytree'
		'linux-headers-amd64' 'wmctrl' 'gnome-colors' 'peek'
		'lightdm-gtk-greeter-settings' 'xfce4-panel-profiles'
	)
	print_status "Doing an update."
	sudo apt-get update >> $logfile
	for package in "${software[@]}";do
		print_status "Installing: $package"
		sudo apt-get -y install $package >> $logfile
	done
	print_status "Done installing basic utilities/software."
}

install_snap_tools(){
	print_header "Snap packages auto-cpufreq and Video-Downloader"
	local logfile="$LOG_DIR/install_snap_tools.log"
	print_status "Doing an update."
	sudo apt-get update >> $logfile
	print_status "Installing: snapd"
	sudo apt-get -y install snapd >> $logfile
	if [ $? -eq 0 ];then
		print_status "Installing snap: core"
		sudo snap install core >> $logfile
		print_status "Installing snap: video-downloader"
		sudo snap install video-downloader >> $logfile
		print_status "Installing snap: auto-cpufreq"
		sudo snap install auto-cpufreq >> $logfile
		print_status "Finished Setting Up Snap software."
	else
		print_error "Failed to install snapd"
	fi
}

install_virtualbox(){
	local logfile="$LOG_DIR/install_virtualbox.log"
	local vboxasc="https://www.virtualbox.org/download/oracle_vbox_2016.asc"
	local vboxascout="/usr/share/keyrings/oracle-virtualbox-2016.gpg"
	local vboxexturl="https://download.virtualbox.org/virtualbox/7.0.12/Oracle_VM_VirtualBox_Extension_Pack-7.0.12.vbox-extpack"
	local vboxext=`echo $vboxexturl | awk -F '/' '{print $6}'`
	print_header "VirtualBox and VirtualBox Extension Pack."
	print_status "Importing GPG keys from ${vboxasc}"
	wget -O- -q $vboxasc | sudo gpg --dearmor -o $vboxascout >> $logfile
	if [ $? -eq 0 ]; then
		print_status "Adding VirtualBox Repository."
		echo "deb [arch=amd64 signed-by=${vboxascout}] http://download.virtualbox.org/virtualbox/debian bookworm contrib" | \
			sudo tee /etc/apt/sources.list.d/virtualbox.list >> $logfile
		if [ $? -eq 0 ]; then
			print_status "Doing an update."
			sudo apt-get update
			print_status "Installing: VirtualBox"
			sudo apt-get -y install virtualbox-7.0 >> $logfile
			if [ $? -eq 0 ]; then
				print_status "Adding $USER to vboxusers"
				sudo usermod -aG vboxusers $USER
				print_status "Donwloading extension pack from ${vboxexturl}"
				wget -q $vboxexturl
				sudo vboxmanage extpack install $vboxext | tee -a $logfile
			fi
		fi
	fi
	rm $vboxext
	print_status "Done Installing VirtualBox and VirtualBox Extension Pack."
}

configure_repos(){
	local logfile="$LOG_DIR/configure_repos.log"
	print_header "Configuring Debian Repositories."
	sudo mv /etc/apt/sources.list /etc/apt/sources.list_old
	local sources_list="
		\rdeb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware\n
		\rdeb-src http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware\n
		\rdeb http://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware\n
		\rdeb-src http://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware\n
		\rdeb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware\n
		\rdeb-src http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware"
	echo -e $sources_list | sudo tee /etc/apt/sources.list > $logfile
	print_status "Finished Configuring Debian Repositories."
}

install_nvidia_drivers(){
	local logfile="$LOG_DIR/install_nvidia_drivers.log"
	print_header "Installing Nvidia Graphics Drivers."
	echo -ne "\e[1;36m[+] Install NVIDIA Graphics Drivers?[Y/n]>>\e[0m "
	read user_input
	if [ "${user_input,,}" == "y" ];then
		print_status "Doing an update."
		sudo apt-get update >> $logfile
		print_status "Installing: nvidia-driver"
		sudo apt-get -y install nvidia-driver >> $logfile
		print_status "Installing: firmware-misc-nonfree"
		sudo apt-get -y install firmware-misc-nonfree >> $logfile
		if [ $? -eq 0 ]; then
			print_status "Finished Installing Nvidia Graphics Drivers."
		else
			print_error "Something went wrong. Nvidia Drivers not installed!"
		fi 
	else
		echo -ne "\e[1;31m[+] Will not Install NVIDIA Graphics Drivers\n\e[0m"
	fi
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

install_discord_plus(){
	print_header "Setting Up Discord_plus"
	local giturl="https://github.com/t0nyc23/discord_plus"
	local cloned=$HOME/.local/share/Discord_plus
	print_status "Cloning Repository"
	git clone $giturl $cloned
	print_status "Running install script"
	cd $cloned && bash install.sh && cd -
	print_status "Discord_plus is now installed"
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
