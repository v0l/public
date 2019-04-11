#!/bin/bash

WIPE_DAY=5
DOW=$(date +\%u)
DOM=$(date +\%d)

HOME_PATH="/home/steam"
SERVER_IDENT="my_server_identity"
RUST_SERVER_DIR="$HOME_PATH/Steam/steamapps/common/rust_dedicated/server"
RUST_RCON_WS="ws://localhost:28016/WEB_RCON_PASSWORD_HERE"
RUST_PROC=$(ps u | awk '$11 ~ /^\.\/RustDedicated/ {print $2}')
DISCORD_WEBHOOK="MY_WEBHOOK_HERE"

echo -e "==== Running wipe script ====\n$(date)\n"
echo -e "Rust PID: $RUST_PROC"
echo -e "Date is: $DOM"
echo -e "Day of week is: $DOW\n"

cd $HOME_PATH

if [ -x $HOME_PATH/websocat ]; then
    echo "websocat found: $($HOME_PATH/websocat --version)"
else
    echo "Downloading websocat.."
    wget -O $HOME_PATH/websocat https://github.com/vi/websocat/releases/download/v1.4.0/websocat_amd64-linux-static
    chmod +x $HOME_PATH/websocat
fi

if [ $DOW -ne $WIPE_DAY ]; then
    echo "Today is not a wipe day.."
    exit
fi

SendDiscordMsg() {
    curl -X POST --data "{\"content\":\"$1\"}" $DISCORD_WEBHOOK
}

UpdateRust() {
    $HOME_PATH/steamcmd.sh +login anonymous +app_update 258550 +quit
}

MakeNewSeed() {
    echo $RANDOM > $HOME_PATH/.rust_seed
}

BackupRust() {
    tar cfjv "$RUST_SERVER_DIR/$SERVER_IDENT_$(date +'%Y%m%d_%H%M').tar.bz" "$RUST_SERVER_DIR/$SERVER_IDENT/"
    echo "Backup created: $RUST_SERVER_DIR/$SERVER_IDENT_$(date +'%Y%m%d_%H%M').tar.bz"
}

SendRustRCON() {
    echo "{\"Identifier\":1,\"Message\":\"$1\",\"Name\":\"WebRcon\"}" | $HOME_PATH/websocat -E $RUST_RCON_WS
}

StopRust() {
    if [ -z $RUST_PROC ]; then
        echo -e "\t-Rust is not running, skipping.."
        return 0
    fi

    WX=5
    while [ $WX -gt 0 ]; do
        echo -e "\t>> Server wipe will start in $WX mins.."
        SendRustRCON "say Server wipe will start in $WX mins.."
        sleep 1m
        (( WX-- ))
    done

    echo -e "\t>> Server wipe starting.."
    SendRustRCON "say Server wipe starting.."
    sleep 10
    SendRustRCON "save"
    SendRustRCON "quit"

    echo "\t-Waiting for rust to exit.."
    tail --pid=$RUST_PROC -f /dev/null
}

DeleteOldMaps() {
    rm -rf "$RUST_SERVER_DIR/$SERVER_IDENT/*.sav" "$RUST_SERVER_DIR/$SERVER_IDENT/*.map"
}

SetTitle() {
    echo "$(date +%b\ %d) ($(date +%H%p\ %Z))" > $HOME_PATH/.rust_wipe_txt
}
StartRustDedicated() {
    #screen -dmS rust $HOME_PATH/rustasia.sh
}

if [ $DOM -gt 14 -a $DOM -lt 22 ]; then
    echo "== Running partial wipe =="
    echo -e "\t-Creating backup.." && BackupRust
    echo -e "\t-Updating RustDedicated.." && UpdateRust
    echo -e "\t-Set new seed.." && MakeNewSeed && echo "New seed: $(cat ~/.rust_seed)"
    echo -e "\t-Stopping RustDedicated.." && SetTitle && StopRust

    echo -e "\t-Wiping BP's.."
    mv $RUST_SERVER_DIR/$SERVER_IDENT/player.blueprints.db ~/rust-bp-partial-wipe
    cd ~/rust-bp-partial-wipe && dotnet run --project rust_wipe
    mv ~/rust-bp-partial-wipe $RUST_SERVER_DIR/$SERVER_IDENT/

    echo -e "\t-Deleting old maps.." && DeleteOldMaps
    echo -e "\t-Done!..\n\t-Starting RustDedicated.." && StartRustDedicated
    SendDiscordMsg "@here Server wiped!" 
elif [ $DOM -lt 8 ]; then
    echo "== Running full wipe =="
    echo -e "\t-Creating backup.." && BackupRust
    echo -e "\t-Updating RustDedicated.." && UpdateRust
    echo -e "\t-Set new seed.." && MakeNewSeed && echo "New seed: $(cat ~/.rust_seed)"
    echo -e "\t-Stopping RustDedicated.." && SetTitle && StopRust
    echo -e "\t-Wiping BP's.." && rm -rf $RUST_SERVER_DIR/$SERVER_IDENT/*.db
    echo -e "\t-Deleting old maps.." && DeleteOldMaps
    echo -e "\t-Done!..\n\tStarting RustDedicated.." && StartRustDedicated
    SendDiscordMsg "@here Server wiped!"
else
    echo "== Running map wipe =="
    echo -e "\t-Creating backup.." && BackupRust
    echo -e "\t-Updating RustDedicated.." && UpdateRust
    echo -e "\t-Set new seed.." && MakeNewSeed && echo "New seed: $(cat ~/.rust_seed)"
    echo -e "\t-Stopping RustDedicated.." && SetTitle && StopRust
    echo -e "\t-Deleting old maps.." && DeleteOldMaps
    echo -e "\t-Done!..\n\t-Starting RustDedicated.." && StartRustDedicated
    SendDiscordMsg "@here Server wiped!"
fi
