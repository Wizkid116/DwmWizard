#!/bin/bash
set -e
$SRC=~/dwmwizard
$BLD=~/dwmwizard/build
mkdir $BLD

cd $BLD
	wget https://dl.suckless.org/dwm/dwm-6.5.tar.gz
	wget https://dl.suckless.org/dmenu/dmenu-5.3.tar.gz
	wget https://dl.suckless.org/tools/slstatus-1.0.tar.gz
	tar xvf dwm-*.tar.gz
	tar xvf dmenu-*.tar.gz
	tar xvf slstatus-*.tar.gz
	sudo -v

cd $BLD/slstatus-*
	echo "Building slstatus"
	cp $SRC/slstatus $BLD/slstatus-*/config.h
	sudo make clean install

cd $BLD/dmenu-*
	echo "Building dmenu"
	sudo make clean install

cd $BLD/dwm-*
	echo "Building dwm"
	cp $SRC/dwm $BLD/dwm-*/config.h
	sudo make clean install

cd $BLD
	echo "Cleaning up"
	rm slstatus-*.tar.gz
	rm dmenu-*.tar.gz
	rm dwm-*.tar.gz
	cd $SRC && cp xdefaults ~/.Xdefaults

exit 0
