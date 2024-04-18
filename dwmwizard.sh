#!/bin/sh
#use set -n for debugging
set -n
source deps

if ! [ $(id -u) = 0]; then
	ehco "ERROR: Please run script as root or with sudo"
	exit 1
fi
# experimental function for building programs
# build_program "$SLSTATUS_DIR" "slstatus"
compile(){
    local dir=$1
    local name=$2
    echo "Building $name"
    cd $dir
    cp "$SRC/$name" "$dir/config.h"
    sudo make clean install
    if [ $? -ne 0 ]; then
        echo "Error building $name"
        exit 1
    fi
}

#checks if the build directory exists. 
#If not, will sleep for 5 seconds then rebuilds everything
if [ ! -d $BLD ]; then
	mkdir $BLD
else 
       	echo "Build directory already exists, rebuilding..."
	for ((i=5; i>=1; i--)); do
		echo $i
		sleep 1
	done
fi
#Check for dependencies, then download them based on distro
if command -v pacman >/dev/null; then #Arch
	pacman -Syy
	pacman -S libx11 libxft libxinerama freetype2 
elif command -v apt-get >/dev/null; then #Debian/Ubuntu
	apt update
	apt install -y libx11 libxft2 libxinerama-1
elif command -v dnf >/dev/null; then #RHEL/Fedora
	dnf update
	dnf install -y libX11 libXft libXinerama freetype
elif command -v emerge >/dev/null; then #Gentoo
	emerge --sync
	emerge -a x11-libs/libX11 x11-libs/libXft libXinerama media-libs/freetype
elif command -v xbps-install >/dev/null; then #Void
	xbps-install -S libX11-devel libXft-devel libXinerama-devel
elif command -v nix-env >/dev/null; then #NixOS
	nix-channel --update
	nix-env -i xorg.libX11 xorg.libXft xorg.libXinerama freetype
else echo "Unsupported distro!"
	exit 2
fi
#downloads and extracts programs
cd $BLD
	wget $DWMDL && wget $DMUDL && wget $SLSDL
	cat *.tar.gz | tar -xvf - -i
	rm *.tar.gz

#builds Slstatus
cd $SLS
	echo "Building slstatus"
	cp $SRC/slstatus $SLS/config.h
	make clean install
#builds Dmenu
cd $DMU
	echo "Building dmenu"
	make clean install
#builds DWM
cd $DWM
	echo "Building dwm"
	cp $SRC/dwm $DWM/config.h
	make clean install
#copies config files for urxvt and LightDM to the proper places, 
#copies startdwm script to /usr/local/bin, and makes it executable
cd $BLD
	echo "Configuring urxvt"
	cd $SRC && cp urxvt ~/.Xdefaults
	cp startdwm /usr/local/bin/startdwm
	cp desktop /usr/share/xsessions/dwm.desktop
	chmod +x /usr/local/bin/startdwm
echo "Installation complete"
exit 0
