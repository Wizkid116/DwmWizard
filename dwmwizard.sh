#!/bin/bash
#use set -n for debugging
set -n
source deps
#checks if the build directory exists. If not, will sleep for 5 seconds then rebuilds everything
if [ ! -d $BLD ]; then
	mkdir $BLD
else 
       	echo "Build directory already exists, rebuilding..."
	for ((i=5; i>=1; i--)); do
		echo $i
		sleep 1
	done
fi
#downloads and extracts programs
cd $BLD
	wget $DL1 && wget $DL2 && wget $DL3
	cat *.tar.gz | tar -xvf - -i
	rm *.tar.gz
	sudo -v
#builds Slstatus
cd $SLS
	echo "Building slstatus"
	cp $SRC/slstatus $SLS/config.h
	sudo make -j$(nproc) clean install
#builds Dmenu
cd $DMU
	echo "Building dmenu"
	sudo make -j$(nproc) clean install
#builds DWM
cd $DWM
	echo "Building dwm"
	cp $SRC/dwm $DWM/config.h
	sudo make -j$(nproc) clean install
#copies config files for urxvt and LightDM to the proper places, 
#copies startdwm script to /usr/local/bin, and makes it executable
cd $BLD
	echo "Configuring urxvt"
	cd $SRC && cp urxvt ~/.Xdefaults
	sudo cp startdwm /usr/local/bin/startdwm
	sudo cp desktop /usr/share/xsessions/dwm.desktop
	sudo chmod +x /usr/local/bin/startdwm
echo "Installation complete"
exit 0
