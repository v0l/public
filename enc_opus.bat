@echo off

for %%f in (*.flac) do ffmpeg -i "%%f" -y -vn -c:a libopus -b:a 128k "%%~nf.ogg"