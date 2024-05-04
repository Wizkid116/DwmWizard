#!/bin/bash
#use set -n for debugging
set -euo pipefail
sudo -v
source deps

#copy config file, and compile the specified program
compile_function(){
  local dir=$1
  local name=$2
  cd $dir
  cp "$SRC/$name" "$dir/config.h"
  sudo make clean install
  if [ $? -ne 0 ]; then
    echo "ERROR: $name failed to compile"
    exit 1
  fi
}

#uninstall programs and config files
uninstall_function(){
  echo "Uninstalling..."
  #remove installed programs
  sudo make -C "$SLS" uninstall
  sudo make -C "$DMU" uninstall
  sudo make -C "$DWM" uninstall
  #remove config files
  rm ~/.Xdefaults
  sudo rm  /bin/startdwm
  sudo rm /usr/share/xsessions/dwm.desktop
  rm -rf $BLD
  echo "Uninstallation complete"
}

#checks for arguments passed to the script
if [ $# == 0 ]; then
  echo "No argument provided"
  echo "Usage: Install, Uninstall"
  exit 3
elif [ "$1" == "uninstall" ]; then
  uninstall_function
  exit 0
elif [ "$1" == "install" ]; then
  echo "Installing..."
else
  echo "Invalid argument"
  echo "Usage: Install, Uninstall"
  exit 4
fi

#check if build directory exists. If not, sleep for 5 seconds then rebuild everything
if [ ! -d $BLD ]; then
	mkdir $BLD
else 
	echo "Build directory already exists, rebuilding..."
	for ((i=5; i>=1; i--)); do
		echo $i
		sleep 1
	done
fi

#Check what package manager is running, then download dependencies.
if command -v pacman >/dev/null; then #Arch
	sudo pacman -Syy
	sudo pacman -S --needed libx11 libxft libxinerama freetype2 
elif command -v apt-get >/dev/null; then #Debian/Ubuntu
	sudo apt update
	sudo apt install -y libx11 libxft2 libxinerama-1
elif command -v dnf >/dev/null; then #RHEL/Fedora
	sudo dnf update
	sudo dnf install -y libX11 libXft libXinerama freetype
elif command -v emerge >/dev/null; then #Gentoo
	sudo emerge --sync
	sudo emerge -a x11-libs/libX11 x11-libs/libXft libXinerama media-libs/freetype
elif command -v xbps-install >/dev/null; then #Void
	sudo xbps-install -S libX11-devel libXft-devel libXinerama-devel
elif command -v nix-env >/dev/null; then #NixOS
	sudo nix-channel --update
	sudo nix-env -i xorg.libX11 xorg.libXft xorg.libXinerama freetype
else echo "ERROR: Unsupported distro"
	exit 2
fi

#download and extract programs
cd $BLD
	wget $DL1 && wget $DL2 && wget $DL3
	cat *.tar.gz | tar -xzf - -i
	rm *.tar.gz

#compile slstatus, dmenu, and dwm respectively
compile_function "$SLS" "slstatus"
compile_function "$DMU" "dmenu"
compile_function "$DWM" "dwm"

#copies config files for urxvt and LightDM to the proper places, 
#copies startdwm script to /usr/local/bin, and makes it executable
cd $SRC
	echo "Configuring urxvt"
	cp urxvt ~/.Xdefaults && cp pepe.png ~/pepe.png
	sudo cp startdwm /bin/startdwm
	sudo cp desktop /usr/share/xsessions/dwm.desktop
	sudo chmod +x /bin/startdwm
echo "Installation complete"
exit 0
