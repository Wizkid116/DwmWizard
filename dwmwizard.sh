#!/bin/bash
set -e
SRC=~/DwmWizard
BLD=$SRC/build
DWM=$SRC/build/dwm-6.5
SLS=$SRC/build/slstatus-1.0
DMU=$SRC/build/dmenu-5.3
if [ ! -d $BLD ]; then
	mkdir $BLD
else 
       	echo "Build directory already exists, rebuilding..."
	for ((i=5; i>=1; i--)); do
		echo $i
		sleep 1
	done
fi

cd $BLD
	wget https://dl.suckless.org/dwm/dwm-6.5.tar.gz
	wget https://dl.suckless.org/tools/dmenu-5.3.tar.gz
	wget https://dl.suckless.org/tools/slstatus-1.0.tar.gz
	tar xvf dwm-*.tar.gz
	tar xvf dmenu-*.tar.gz
	tar xvf slstatus-*.tar.gz
	rm dwm-*.tar.gz
	rm dmenu-*.tar.gz
	rm slstatus-*.tar.gz
	sudo -v

cd $SLS
	echo "Building slstatus"
	cp $SRC/slstatus $SLS/config.h
	sudo make clean install

cd $DMU
	echo "Building dmenu"
	sudo make clean install

cd $DWM
	echo "Building dwm"
	cp $SRC/dwm $DWM/config.h
	sudo make clean install

cd $BLD
	echo "Configuring urxvt"
	cd $SRC && cp urxvt ~/.Xdefaults
  sudo cp startdwm /usr/local/bin/startdwm
  sudo cp desktop /usr/share/xsessions/dwm.desktop
  sudo chmod +x /usr/local/bin/startdwm

  echo "Installation complete"
exit 0
