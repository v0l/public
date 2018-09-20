#!/usr/bin/python

import re
import sys
import os
from subprocess import call, Popen, PIPE

dir_path = os.path.dirname(os.path.realpath(__file__))

while True:
	nginx_pid = Popen('pgrep -P $(cat ~/.nginx/pid) | pase -s -d, -', stdout=PIPE, shell=True)
	ln=0
	proc = Popen(['strace', '-p', nginx_pid.stdout.read(), '-e', 'sendfile'], stdout=PIPE, stderr=PIPE)
	for line in iter(proc.stderr.readline,''):
		ps = re.search('= ([0-9]{1,20})$', line)
		if ps != None:
			print call(['rrdupdate', 'procs/nginx.rrd', '-t', 'out', 'N:' + ps.group(1)])
		
		if ++ln % 10 == 0:
			print call([dir_path + '/nginx_graph_strace.sh'])
