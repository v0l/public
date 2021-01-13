#!/bin/sh
# Usage: ./timelapse.sh <seconds> <out-file>.h264
# Eg. ./timelapse.sh 10 cat

FPS=60
VW=1920
VH=-1 #keep aspect ratio

while [ True ];do gphoto2 --capture-image-and-download --stdout; sleep $1; done | \
    ffmpeg -fflags +genpts -r $FPS -f mjpeg -i - -c:v h264 -g $FPS -b:v 30M -vf scale=$VW:$VH -pix_fmt yuv420p -y -f h264 $2.h264
