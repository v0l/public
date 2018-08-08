#!/bin/sh

#create the nginx.rrd with: 
#rrdcreate procs/nginx.rrd -s 1s DS:in:ABSOLUTE:10s:0:U DS:out:ABSOLUTE:10s:0:U RRA:AVERAGE:0.9:30s:1y

#2hr graph
rrdtool graph nginx_2h.png -v bytes/sec -E -s -2h -S 60 -w 400 -h 100 -z -t "Traffic on: nginx-$(hostname) (2h)" \
DEF:out=procs/nginx.rrd:out:AVERAGE \
VDEF:oavg=out,AVERAGE VDEF:olast=out,LAST \
LINE1:out#f4417a \
GPRINT:oavg:"%5.1lf %sbytes/sec avg out" GPRINT:olast:"%5.1lf %sbytes/sec out now"

#1d graph
rrdtool graph nginx_1d.png -v bytes/sec -E -s -1d -S 900 -w 400 -h 100 -z -t "Traffic on: nginx-$(hostname) (1d)" \
DEF:out=procs/nginx.rrd:out:AVERAGE \
VDEF:oavg=out,AVERAGE VDEF:olast=out,LAST \
LINE1:out#f4417a \
GPRINT:oavg:"%5.1lf %sbytes/sec avg out" GPRINT:olast:"%5.1lf %sbytes/sec out now"

#30d graph
rrdtool graph nginx_30d.png -v bytes/sec -E -s -30d -S 21600 -w 400 -h 100 -z -t "Traffic on: nginx-$(hostname) (30d)" \
DEF:out=procs/nginx.rrd:out:AVERAGE \
VDEF:oavg=out,AVERAGE VDEF:olast=out,LAST \
LINE1:out#f4417a \
GPRINT:oavg:"%5.1lf %sbytes/sec avg out" GPRINT:olast:"%5.1lf %sbytes/sec out now"
