@echo off
:loop
"C:\Program Files\Bitcoin\daemon\bitcoin-cli.exe" -conf="F:\Bitcoin\bitcoin_regtest.conf" -rpcport=18443 generatetoaddress 1 2MzwLdkKRKqHtmpbXoYpXjm7SKT8LeGXriM
timeout /t 60
goto loop