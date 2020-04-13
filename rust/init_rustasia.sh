#!/bin/bash
# Cloud-init script for AWS rust server "user-data"

SUSR="steam"
SHOME="/home/$SUSR"
TITLE="MyRustServer"
IDENT="rust_server"
RCON_PASSWORD="password"
WEBHOOK="https://discordapp.com/api/webhooks/XXX"
REPORT_PRIVATE_WEBOOK="https://discordapp.com/api/webhooks/XXX"
REPORT_PUBLIC_WEBHOOK="https://discordapp.com/api/webhooks/XXX"

TZ="Asia/Singapore"

wget https://packages.microsoft.com/config/ubuntu/19.10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb

apt update
apt install -y lib32gcc1 curl wget htop bmon screen apt-transport-https dotnet-runtime-3.1 p7zip netdata

useradd -m -r -s /bin/bash $SUSR

RunAsSteam () {
    sudo -u $SUSR -H "$@"
}

RunAsSteam curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - -C $SHOME

#create run script
RunAsSteam cat >$SHOME/run.sh <<EOL
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:~/Steam/steamapps/common/rust_dedicated:~/Steam/steamapps/common/rust_dedicated/RustDedicated_Data/\$
while true
do
echo "Checking for updates..."
~/steamcmd.sh +login anonymous +app_update 258550 +quit

#echo "Backing up log file..."
#gzip -c "/home/steam/.config/unity3d/Facepunch Studios LTD/Rust/Player.log" > ~/logs/trashlog_$(date +'%Y%m%d_%H%M').txt.gz

echo "Starting server.."

cd ~/Steam/steamapps/common/rust_dedicated && ./RustDedicated -batchmode \\
+rcon.password $RCON_PASSWORD \\
+server.identity "$IDENT" \\
+server.seed \$(cat ~/.rust_seed) \\
+rcon.web 1 \\
+rcon.port 28016 \\
+server.worldsize 3500 \\
+server.maxplayers 200 \\
+server.hostname "$TITLE ~Wiped \$(cat ~/.rust_wipe_txt)" \\
+server.description "https://discord.rustasia.com" \\
+server.url "https://discord.rustasia.com" \\
+server.headerimage "https://rustasia.com/rustasia_banner.png"
done
EOL

#create wipe script
RunAsSteam cat >$SHOME/wipe.sh <<EOL
#!/bin/bash

WIPE_DAY=5
DOW=\$(date +\%u)
DOM=\$(date +\%d)

HOME_PATH="$SHOME"
SERVER_IDENT="$IDENT"
RUST_SERVER_DIR="\$HOME_PATH/Steam/steamapps/common/rust_dedicated/server"
RUST_RCON_WS="ws://localhost:28016/$RCON_PASSWORD"
RUST_PROC=\$(ps u | awk '\$11 ~ /^\.\/RustDedicated/ {print \$2}')
DISCORD_WEBHOOK="$WEBHOOK"

SendDiscordMsg() {
    curl -X POST --data "{\"content\":\"\$1\"}" -H "Content-Type: application/json" \$DISCORD_WEBHOOK
}

UpdateRust() {
    \$HOME_PATH/steamcmd.sh +login anonymous +app_update 258550 +quit
}

MakeNewSeed() {
    echo \$RANDOM > \$HOME_PATH/.rust_seed
}

BackupRust() {
    tar cfjv "$RUST_SERVER_DIR/$SERVER_IDENT_\$(date +'%Y%m%d_%H%M').tar.bz" "\$RUST_SERVER_DIR/\$SERVER_IDENT/"
    echo "Backup created: \$RUST_SERVER_DIR/\$SERVER_IDENT_\$(date +'%Y%m%d_%H%M').tar.bz"
}

SendRustRCON() {
    echo "{\"Identifier\":1,\"Message\":\"\$1\",\"Name\":\"WebRcon\"}" | \$HOME_PATH/websocat -E \$RUST_RCON_WS
}

StopRust() {
    if [ -z \$RUST_PROC ]; then
        echo -e "\t-Rust is not running, skipping.."
        return 0
    fi

    WX=5
    while [ \$WX -gt 0 ]; do
        echo -e "\t>> Server \$1 wipe will start in \$WX mins.."
        SendRustRCON "say Server \$1 wipe will start in \$WX mins.."
        sleep 1m
        (( WX-- ))
    done

    echo -e "\t>> Server \$1 wipe starting.."
    SendRustRCON "say Server \$1 wipe starting.."
    sleep 10
    SendRustRCON "save"
    SendRustRCON "quit"

    echo -e "\t-Waiting for rust to exit.."
    tail --pid=\$RUST_PROC -f /dev/null
}

DeleteOldMaps() {
    rm -rf \$RUST_SERVER_DIR/\$SERVER_IDENT/*.sav 
    rm -rf \$RUST_SERVER_DIR/\$SERVER_IDENT/*.map
}

SetTitle() {
    echo "\$(date +%b\ %d) (\$(date +%H%p\ %Z))" > \$HOME_PATH/.rust_wipe_txt
}

StartRustDedicated() {
    #screen -dmS rust $HOME_PATH/rustasia.sh
    echo "...."
}

###################################################
echo -e "==== Running wipe script ====\n\$(date)\n"
echo -e "Rust PID: \$RUST_PROC"
echo -e "Date is: \$DOM"
echo -e "Day of week is: \$DOW\n"

cd \$HOME_PATH

if [ -x \$HOME_PATH/websocat ]; then
    echo "websocat found: \$(\$HOME_PATH/websocat --version)"
else
    echo "Downloading websocat.."
    wget -O \$HOME_PATH/websocat https://github.com/vi/websocat/releases/download/v1.5.0/websocat_amd64-linux-static
    chmod +x \$HOME_PATH/websocat
fi

if [ \$DOW -ne \$WIPE_DAY ]; then
    echo "Today is not a wipe day.."
    exit
fi

if [ \$DOM -gt 14 -a \$DOM -lt 22 ]; then
    echo "== Running partial wipe =="
    echo -e "\t-Creating backup.." && BackupRust
    echo -e "\t-Updating RustDedicated.." && UpdateRust
    echo -e "\t-Set new seed.." && MakeNewSeed && echo "New seed: \$(cat ~/.rust_seed)"
    echo -e "\t-Stopping RustDedicated.." && SetTitle && StopRust "partial"

    echo -e "\t-Wiping BP's.."
    mv \$RUST_SERVER_DIR/\$SERVER_IDENT/player.blueprints.3.db ~/rust-bp-partial-wipe/player.blueprints.3.db
    cd ~/rust-bp-partial-wipe && dotnet run --project rust_wipe
    mv ~/rust-bp-partial-wipe/player.blueprints.3.db \$RUST_SERVER_DIR/\$SERVER_IDENT/player.blueprints.3.db

    echo -e "\t-Deleting old maps.." && DeleteOldMaps
    echo -e "\t-Done!..\n\t-Starting RustDedicated.." && StartRustDedicated
    SendDiscordMsg "@everyone Server map + T3 BP\'s wiped!" 
elif [ \$DOM -lt 9 -a $DOM -ne 1 ]; then
    echo "== Running full wipe =="
    echo -e "\t-Creating backup.." && BackupRust
    echo -e "\t-Updating RustDedicated.." && UpdateRust
    echo -e "\t-Set new seed.." && MakeNewSeed && echo "New seed: \$(cat ~/.rust_seed)"
    echo -e "\t-Stopping RustDedicated.." && SetTitle && StopRust "full"
    echo -e "\t-Wiping BP's.." && rm -rf \$RUST_SERVER_DIR/\$SERVER_IDENT/*.db
    echo -e "\t-Deleting old maps.." && DeleteOldMaps
    echo -e "\t-Done!..\n\tStarting RustDedicated.." && StartRustDedicated
    SendDiscordMsg "@everyone FULL Server wiped!"
else
    echo "== Running map wipe =="
    echo -e "\t-Creating backup.." && BackupRust
    echo -e "\t-Updating RustDedicated.." && UpdateRust
    echo -e "\t-Set new seed.." && MakeNewSeed && echo "New seed: \$(cat ~/.rust_seed)"
    echo -e "\t-Stopping RustDedicated.." && SetTitle && StopRust "map"
    echo -e "\t-Deleting old maps.." && DeleteOldMaps
    echo -e "\t-Done!..\n\t-Starting RustDedicated.." && StartRustDedicated
    SendDiscordMsg "@everyone Server map wiped!"
fi
EOL

#Setup RustLogger
mkdir /usr/local/RustLogger
cd /usr/local/RustLogger && wget https://v0l.io/RustLogger.7z
cd /usr/local/RustLogger && p7zip -d RustLogger.7z

cat | crontab - <<EOF
* * * * * $(which flock) -xn /root/.RustLogger.lock $(which dotnet) /usr/local/RustLogger/RustLogger.dll ws://localhost:28016/$RCON_PASSWORD $REPORT_PRIVATE_WEBOOK $REPORT_PUBLIC_WEBHOOK 2>&1 1>>/var/log/rust.log
EOF

#Change timezone
timedatectl set-timezone $TZ
timedatectl set-ntp 1
echo NTP=time.google.com >> /etc/systemd/timesyncd.conf
systemctl restart systemd-timesyncd

#add iptables rules
iptables -F INPUT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -p udp --dport 28015 -m state --state NEW -m u32 --u32 "0x1c=0xffffffff&&0x20=0x54536f75" -m comment --comment "Steam server query" -j ACCEPT
iptables -A INPUT -p udp --dport 28015 -m state --state NEW -m u32 --u32 "0x19&0xf=0x5" -m comment --comment "RakNet open connection packet type" -j ACCEPT
iptables -A INPUT -p tcp --dport 28016 -m comment --comment "RCON port" -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 19999 -j ACCEPT
iptables -P INPUT DROP
iptables-save > /etc/iptables/rules.v4

#create info files
cat >$SHOME/.rust_wipe_txt <<EOL
$(date +%b\ %d) ($(date +%H%p\ %Z))
EOL

cat >$SHOME/.rust_seed <<EOL
$RANDOM
EOL

chown $SUSR:$SUSR $SHOME/ -R
chmod +x $SHOME/run.sh $SHOME/wipe.sh
RunAsSteam /usr/bin/screen -dmS rust $SHOME/run.sh