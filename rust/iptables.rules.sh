#!/bin/sh

#some rules to stop DDoS on rust server port, allow only valid new connections.

iptables -A INPUT -p udp --dport 28015 -m state --state NEW -m u32 --u32 "0x1c=0xffffffff&&0x20=0x54536f75" -m comment --comment "Steam server query" -j ACCEPT
iptables -A INPUT -p udp --dport 28015 -m state --state NEW -m u32 --u32 "0x19&0xf=0x5" -m comment --comment "RakNet open connection packet type" -j ACCEPT
iptables -A INPUT -p udp --dport 28015 -m state --state NEW -j DROP