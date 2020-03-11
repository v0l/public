export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:~/Steam/steamapps/common/rust_dedicated:~/Steam/steamapps/common/rust_dedicated/RustDedicated_Data/$
while true
do
echo "Checking for updates..."
~/steamcmd.sh +login anonymous +app_update 258550 +quit

#echo "Backing up log file..."
#gzip -c "/home/steam/.config/unity3d/Facepunch Studios LTD/Rust/Player.log" > ~/logs/trashlog_$(date +'%Y%m%d_%H%M').txt.gz

echo "Starting server.."

cd ~/Steam/steamapps/common/rust_dedicated && ./RustDedicated -batchmode \
+rcon.password password \
+server.identity "sg.rustasia.com" \
+server.seed $(cat ~/.rust_seed) \
+rcon.web 1 \
+rcon.port 28016 \
+server.worldsize 3500 \
+server.maxplayers 200 \
+server.hostname "[SEA] RustAsia.com ~Wiped $(cat ~/.rust_wipe_txt)" \
+server.description "https://discord.rustasia.com" \
+server.url "https://discord.rustasia.com" \
+server.headerimage "https://rustasia.com/rustasia_banner.png"
done
