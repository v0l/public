#!/bin/bash

WIPE_DAY=4
DOW=$(date +\%u)
DOM=$(date +\%d)

SERVER_IDENT="######################"
RUST_SERVER_DIR="~/Steam/steamapps/common/rust_dedicated/server/"
RUST_RCON_WS="ws://localhost:28016/###############"
RUST_PROC=$(ps u | awk '$11 ~ /^\.\/RustDedicated/ {print $2}')

echo -e "==== Running wipe script ====\n$(date)\n"
echo -e "Rust PID: $RUST_PROC"
echo -e "Date is: $DOM"
echo -e "Day of week is: $DOW\n"

if [ -x websocat ]; then
    echo "websocat found: $(~/websocat --version)"
else
    echo "Downloading websocat.."
    wget -O ~/websocat https://github.com/vi/websocat/releases/download/v1.4.0/websocat_amd64-linux-static
    chmod +x ~/websocat
fi

if [ $DOW -ne $WIPE_DAY ]; then
    echo "Today is not a wipe day.."
    exit
fi

UpdateRust() {
    ~/steamcmd.sh +login anonymous +app_update 258550 +quit
}

MakeNewSeed() {
    echo $RANDOM > ~/.rust_seed
}

BackupRust() {
    cd $RUST_SERVER_DIR && tar cfjv "$SERVER_IDENT_$(date +'%Y%m%d_%H%M').tar.bz" "$_SERVER_IDENT/"
    echo "Backup created: $RUST_SERVER_DIR/$SERVER_IDENT_$(date +'%Y%m%d_%H%M').tar.bz"
}

StopRust() {
    WX=5
    while [ $WX -gt 0 ]; do
        echo -e "\t>> Server wipe will start in $WX mins.."
        echo "{\"Identifier\":1,\"Message\":\"say Server wipe will start in $WX mins..\",\"Name\":\"WebRcon\"}" | websocat -E $RUST_RCON_WS
        sleep 1m
        (( WX-- ))
    done

    echo -e "\t>> Server wipe starting.."
    echo "{\"Identifier\":1,\"Message\":\"say Server wipe starting..\",\"Name\":\"WebRcon\"}" | websocat -E $RUST_RCON_WS
    sleep 10
    echo "{\"Identifier\":1,\"Message\":\"save\",\"Name\":\"WebRcon\"}" | websocat -E $RUST_RCON_WS
    echo "{\"Identifier\":1,\"Message\":\"quit\",\"Name\":\"WebRcon\"}" | websocat -E $RUST_RCON_WS

    wait $RUST_PROC
}

DeleteOldMaps() {
    rm -rf "$RUST_SERVER_DIR/$SERVER_IDENT/*.sav" "$RUST_SERVER_DIR/$SERVER_IDENT/*.map"
}

StartRustDedicated() {
    echo "$(date +%b\ %d) ($(date +%H%p\ %Z))" > ~/.rust_wipe_txt
    screen -dmS rust ~/rustasia.sh
}

if [ $DOM -gt 8 -a $DOM -lt 15 ]; then
    echo "== Running partial wipe =="
    echo -e "\tCreating backup.." && BackupRust
    echo -e "\tUpdating RustDedicated.." && UpdateRust
    echo -e "\tSet new seed.." && MakeNewSeed && echo "New seed: $(cat ~/.rust_seed)"
    echo -e "\tStopping RustDedicated.." && StopRust

    echo -e "\tWiping BP's.."
    mv $RUST_SERVER_DIR/$SERVER_IDENT/player.blueprints.db ~/rust-bp-partial-wipe
    cd ~/rust-bp-partial-wipe && dotnet run --project rust_wipe
    mv ~/rust-bp-partial-wipe $RUST_SERVER_DIR/$SERVER_IDENT/

    echo -e "\tDeleting old maps.." && DeleteOldMaps
    echo -e "\tDone!..\n\tStarting RustDedicated.." && StartRustDedicated
elif [ $DOM -lt 8 ]; then
    echo "== Running full wipe =="
    echo -e "\tCreating backup.." && BackupRust
    echo -e "\tUpdating RustDedicated.." && UpdateRust
    echo -e "\tSet new seed.." && MakeNewSeed && echo "New seed: $(cat ~/.rust_seed)"
    echo -e "\tStopping RustDedicated.." && StopRust
    echo -e "\tWiping BP's.." && rm -rf $RUST_SERVER_DIR/$SERVER_IDENT/*.db
    echo -e "\tDeleting old maps.." && DeleteOldMaps
    echo -e "\tDone!..\n\tStarting RustDedicated.." && StartRustDedicated
else
    echo "== Running map wipe =="
    echo -e "\tCreating backup.." && BackupRust
    echo -e "\tUpdating RustDedicated.." && UpdateRust
    echo -e "\tSet new seed.." && MakeNewSeed && echo "New seed: $(cat ~/.rust_seed)"
    echo -e "\tStopping RustDedicated.." && StopRust
    echo -e "\tDeleting old maps.." && DeleteOldMaps
    echo -e "\tDone!..\n\tStarting RustDedicated.." && StartRustDedicated
fi
