#!/bin/sh

#create the nginx.rrd with: 
#rrdcreate procs/nginx.rrd -s 1s DS:in:ABSOLUTE:10s:0:U DS:out:ABSOLUTE:10s:0:U RRA:AVERAGE:0.9:30s:1y

rrdtool graph nginx_2h.png -v bytes/sec -E -s -2h -S 60 -w 400 -h 100 -z -t "Traffic on: nginx-$(hostname)" \
DEF:out=procs/nginx.rrd:out:AVERAGE \
VDEF:oavg=out,AVERAGE VDEF:olast=out,LAST \
LINE1:out#f4417a \
GPRINT:oavg:"%5.1lf %sbytes/sec avg out" GPRINT:olast:"%5.1lf %sbytes/sec out now"
