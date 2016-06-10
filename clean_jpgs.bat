@echo off

for %%s in (*.jpg) do (
	ffmpeg -i %%s -y -map_metadata -1 %%s_v2.jpg
)