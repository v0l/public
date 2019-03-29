function FindProxyForURL(url, host){
	if(isInNet(host, "192.168.2.0", "255.255.255.0") || isInNet(host, "10.10.0.0", "255.255.255.252")) {
		return "DIRECT";
	}
    return "SOCKS5 192.168.2.10:9150";
}  
