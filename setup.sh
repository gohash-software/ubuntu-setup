#!/usr/bin/env sh

# Quick and dirty script to install all the basic software
# the gohash developer team needs.

set -eu

debian_packages=(
	"neovim"
	"fish"
	"dconf-editor"
	"gnome-tweaks"
	"apt-transport-https"
	"curl"
	"git"
	"inxi"
	"htop"
	"chrome-gnome-shell"
	"gnome-shell-extension-prefs"
	"vlc"
)

snap_packages=(
	"discord"
	"spotify"
	"bitwarden"
	"onlyoffice-desktopeditors"
	"notion-snap"
)

printf '\n'

BOLD="$(tput bold 2>/dev/null || printf '')"
GREY="$(tput setaf 0 2>/dev/null || printf '')"
UNDERLINE="$(tput smul 2>/dev/null || printf '')"
RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
BLUE="$(tput setaf 4 2>/dev/null || printf '')"
MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"
NO_COLOR="$(tput sgr0 2>/dev/null || printf '')"

info() {
	printf '%s\n' "${BOLD}${GREY}>${NO_COLOR} $*"
}

warn() {
	printf '%s\n' "${YELLOW}! $*${NO_COLOR}"
}

error() {
	printf '%s\n' "${RED}x $*${NO_COLOR}" >&2
}

completed() {
	printf '%s\n' "${GREEN}✓${NO_COLOR} $*"
}

has() {
	command -v "$1" 1>/dev/null 2>&1
}

verify_shell_is_posix_or_exit() {
	if [ -n "${ZSH_VERSION+x}" ]; then
		error "Running installation script with \`zsh\` is known to cause errors."
		error "Please use \`sh\` instead."
		exit 1
	elif [ -n "${BASH_VERSION+x}" ] && [ -z "${POSIXLY_CORRECT+x}" ]; then
		error "Running installation script with non-POSIX \`bash\` may cause errors."
		error "Please use \`sh\` instead."
		exit 1
	else
		true  # No-op: no issues detected
	fi
}

pre_hooks() {
	if [ ! -d ~/Downloads/debs ]; then
		info "Creating debs directory..."
		mkdir -p ~/Downloads/debs
	else
		warn "debs directory already exsists"
	fi
}

update_system() {
	info "Updating the system..."
	sudo apt-get update && sudo apt-get upgrade -y
}

install_standard() {
	info "Installing suite of standard programs..."
	for d in ${debian_packages[@]}; do
		if ! has $d; then
			info "Installing "$d""
			sudo apt install $d -y
		fi
	done
}

# install brave and google-chrome
install_browsers() {
	info "Installing browsers..."
	# install brave if it is not already on the system
	if ! has brave-browser; then
		sudo apt install apt-transport-https curl
		sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
		echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
		sudo apt update
		sudo apt install brave-browser -y
		completed "Brave is now installed"
	else
		info "Brave is already installed"
	fi

	# install google chrome if its not already on the system
	if ! has google-chrome; then
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		sudo dpkg -i google-chrome-stable_current_amd64.deb
		mv -v google-chrome-stable_current_amd64.deb ~/Downloads/debs
		completed "Google Chrome is now installed"
	else
		info "Google Chrome is already installed"
	fi
}

install_snaps() {
	info "Installing 3rd party software via snap packages..."
	for s in ${snap_packages[@]}; do
		if ! has $s; then
			info "Installing "$s""
			sudo snap install $s
		fi
	done
}

write_profile() {
	if [ ! -d ~/.local/bin ]; then
		mkdir -p ~/.local/bin
	fi

	if [ ! -f ~/.profile ]; then
		touch ~/.profile
	fi

	echo "export EDITOR=\"nvim\"" >> ~/.profile
	echo "export VISUAL=\"nvim\"" >> ~/.profile
	echo "export TERMINAL=\"gnome-terminal\"" >> ~/.profile
	echo "export BROWSER=\"google-chrome\"" >> ~/.profile
	echo "export READER=\"evince\"" >> ~/.profile
	echo "PATH=~/.local/bin:$PATH" >> ~/.profile
}


cleanup() {
	info "Removing programs we don't need"
	sudo apt remove --purge -y libreoffice-* rhythmbox totem
	sudo snap remove firefox
	info "Removing stale packages and libraries..."
	sudo apt autoremove
}

# execute all the functions
update_system
pre_hooks
install_standard
install_browsers
install_snaps
write_profile
cleanup

completed "Done..."
