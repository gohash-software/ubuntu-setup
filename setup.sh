#!/bin/bash


function pre_hooks() {
	if [[ ! -d ~/Downloads/debs ]]; then
		mkdir -p ~/Downloads/debs
	fi
}

function update_system() {
	sudo apt-get update && sudo apt-get upgrade -y
}

function install_standard() {
	sudo apt install neovim fish dconf-editor gnome-tweaks apt-transport-https curl git inxi htop -y
}

# install brave and google-chrome
function install_browswers() {
	# install brave
	sudo apt install apt-transport-https curl
	sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
	sudo apt update
	sudo apt install brave-browser

	# install google chrome
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo dpkg -i google-chrome-stable_current_amd64.deb
	mv -v google-chrome-stable_current_amd64.deb ~/Downloads/debs
}

function install_snaps() {
	snap install discord spotify bitwarden onlyoffice-desktopeditors
}

function uninstall_useless_programs() {
	sudo apt remove --purge -y libreoffice-* rhythmbox
}

pre_hooks
update_system
install_standard
install_browswers
install_snaps
uninstall_libre_office

sudo apt autoremove
