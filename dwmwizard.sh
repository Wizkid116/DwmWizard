#!/bin/bash
set -e
SRC=~/DwmWizard
BLD=~/$SRC/build
DWM=~/$SRC/build/dwm-6.5
SLS=~/$SRC/build/slstatus-1.0
DMU=~/$SRC/build/dmenu-5.3
mkdir $BLD

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

echo "Installation complete"
exit 0
