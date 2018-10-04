#!/usr/bin/python
# RRDTool script

import time
import re
import os.path
from subprocess import call, Popen, PIPE

GW=400
GH=100

class IfStats:
        def __init__(self, data):
                self.Bytes = data[0]
                self.Packets = data[1]
                self.Errors = data[2]
class IfInfo:
        def __init__(self, data):
                self.Name = data[0]
                self.In = IfStats(data[1:])
                self.Out = IfStats(data[9:])

def GetInterfaceInfo():
        ret=[]
        fin = open('/proc/net/dev', 'r')
        fin.next()
        fin.next()
        for sl in fin:
                data = re.split('\W+', sl.strip())
                ret.append(IfInfo(data))
        return ret

def MakeNetGraph(iface, w, h, st, sp):
        print call(['rrdtool', 'graph', iface + '_' + sp + '_' + st + '.png', '-v', 'bytes/sec', '-E', '-s', '-' + st, '-S', sp, '-w', str(w), '-h', str(h), '-z', '-t', 'Traffic on: ' + iface + ' (' + st + ')', 'DEF:in=nets/' + iface + '.rrd:in:AVERAGE', 'DEF:out=nets/' + iface + '.rrd:out:AVERAGE', 'VDEF:iavg=in,AVERAGE', 'VDEF:oavg=out,AVERAGE', 'VDEF:ilast=in,LAST', 'VDEF:olast=out,LAST', 'LINE1:in#42f44e', 'LINE1:out#f4417a', 'GPRINT:iavg:%5.1lf %sbytes/sec avg in', 'GPRINT:ilast:%5.1lf %sbytes/sec in now\l', 'GPRINT:oavg:%5.1lf %sbytes/sec avg out', 'GPRINT:olast:%5.1lf %sbytes/sec out now\l'])

def UpdateNetGraphs():
	if_data = GetInterfaceInfo()
        for i in if_data:
                print i.Name + ': IN=' + i.In.Bytes + ' OUT=' + i.Out.Bytes
                if os.path.exists('nets/' + i.Name + '.rrd') == False:
                        print 'Creating RRD for: ' + i.Name
                        cret = call(['rrdcreate', 'nets/' + i.Name + '.rrd', '-s', '1s', 'DS:in:COUNTER:10s:0:U', 'DS:out:COUNTER:10s:0:U', 'RRA:AVERAGE:0.9:30s:1y'])
                        if cret != 0:
                                print 'ERROR!'
                cup = call(['rrdupdate', 'nets/' + i.Name + '.rrd', '-t', 'in:out', 'N:' + i.In.Bytes + ':' + i.Out.Bytes])
                if cup != 0:
                        print 'COLLECT ERROR'
                MakeNetGraph(i.Name, GW, GH, '2h', '60')
                MakeNetGraph(i.Name, GW, GH, '1d', '900')
                MakeNetGraph(i.Name, GW, GH, '7d', '3600')
                MakeNetGraph(i.Name, GW, GH, '30d', '21600')

def UpdatePings(ips):
	for ip in ips:
		if os.path.exists('pings/' + ip + '.rrd') == False:
			call(['rrdcreate', 'pings/' + ip + '.rrd', '-s', '1m', 'DS:ping:GAUGE:1m:0:U', 'RRA:AVERAGE:0.99:1m:30d'])

		print 'Sending pings to ' + ip
		proc = Popen(['/bin/ping', '-c', '1', ip], stdout=PIPE)
		ps = re.search('= ([0-9./]+)', proc.stdout.read())
		if ps != None:
			pv = ps.group(0)[2:].split('/')[1]
			print ip + ': ' + pv
			call(['rrdupdate', 'pings/' + ip + '.rrd', '-t', 'ping', 'N:' + pv])
		MakePingGraphs(ip, '60', '1d', GW, GH)
		MakePingGraphs(ip, '3600', '7d', GW, GH)

def MakePingGraphs(ip, step, start, w, h):
	call(['rrdtool', 'graph', ip + '_' + step + '_' + start + '.png', '-v', 'ms rtt', '-E', '-s', '-' + start , '-S' + step, '-w', str(w), '-h', str(h), '-z', '-t', 'Ping time for: ' + ip + ' (' + start + ')', 'DEF:ping=pings/' + ip + '.rrd:ping:AVERAGE', 'AREA:ping#4286f4']) 

lx=0
while True:
	UpdateNetGraphs()
	if lx % 10 == 0:
		UpdatePings(['8.8.8.8'])

	time.sleep(1)
	lx+=1
