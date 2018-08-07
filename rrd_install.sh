#!/bin/bash

#RRDTOOL setup script

#Notes:
#fontconfig: -I$HOME/.local/include
#pkg-config will point to the wrong dir '$HOME/.local/include/uuid' to be exact
#fontconfig tries to include <uuid/uuid.h>

PWD=$(pwd)
BUILD_JOBS=$(nproc --all)
TMP_PATH=$HOME/rrd_build
LOCALPATH=$HOME/.local
INC_PATH=$LOCALPATH/include

SRC=("http://ftp.gnu.org/pub/gnu/gperf/gperf-3.1.tar.gz"
	"https://nchc.dl.sourceforge.net/project/libuuid/libuuid-1.0.3.tar.gz"
	"http://prdownloads.sourceforge.net/libpng/libpng-1.6.35.tar.xz?download"
	"https://download.savannah.gnu.org/releases/freetype/freetype-2.9.tar.gz"
	"https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.0.tar.bz2"
	"https://www.cairographics.org/releases/pixman-0.34.0.tar.gz"
	"https://www.cairographics.org/releases/cairo-1.14.12.tar.xz"
	"https://www.freedesktop.org/software/harfbuzz/release/harfbuzz-1.8.5.tar.bz2"
	"https://github.com/fribidi/fribidi/releases/download/v1.0.5/fribidi-1.0.5.tar.bz2"
	"http://ftp.gnome.org/pub/GNOME/sources/pango/1.42/pango-1.42.3.tar.xz"
	"https://oss.oetiker.ch/rrdtool/pub/rrdtool-1.7.0.tar.gz")

mkdir $TMP_PATH
cd $TMP_PATH

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$LOCALPATH/lib/pkgconfig
export PATH=$PATH:$LOCALPATH/bin

for i in "${SRC[@]}"
do
	wget $i
	INAME=${i##*/}
	tar xfv $INAME
	cd ${INAME%.tar.*} 
	./configure --prefix=$LOCALPATH CFLAGS=-I$INC_PATH 
	make -j$BUILD_JOBS && make install
	cd ..
done

cd $PWD
rm -rf $TMP_PATH