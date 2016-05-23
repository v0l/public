@echo off

ffmpeg -i "%~1" -c:v libvpx-vp9 -b:v 3000k -c:a libopus -b:a 128k -map_metadata -1 -tile-columns 6 -frame-parallel 1 -threads 8 "%~n1.webm"
