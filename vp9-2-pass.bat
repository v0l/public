@echo off

SET /P video=Please enter video to encode: 
SET /P bitrate=Bitrate(1000K): 
SET /P chans=Channels: 
SET /A abitrate=%chans% * 256

echo.
echo Video Bitrate is: %bitrate%K
echo Audio Bitrate is: %abitrate%K
echo Output filename is: %video%.webm
echo.
pause

ffmpeg -i %video% -c:v libvpx-vp9 -pass 1 -b:v %bitrate% -threads 16 -speed 4 -tile-columns 6 -frame-parallel 1 -an -f NULL nil
ffmpeg -i %video% -c:v libvpx-vp9 -pass 2 -b:v %bitrate% -threads 16 -speed 1 -tile-columns 6 -frame-parallel 1 -c:a libopus -b:a %abitrate%K -sample_fmt s16 -map_metadata -1 -c:s copy -f webm %video%.webm
