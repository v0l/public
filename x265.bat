@echo off

SET /P video=Please enter video to encode: 
SET /P crf=Enter crf: 

ffmpeg -i %video% -c:v libx265 -x265-params crf=%crf% -c:a copy -pass 1 -map_metadata -1 -map_chapters -1 -f NULL nil
ffmpeg -i %video% -c:v libx265 -x265-params crf=%crf% -c:a copy -pass 2 -map_metadata -1 -map_chapters -1 %video:~0,-4%.HEVC.mkv
shutdown /s /t 1 /f