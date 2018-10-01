#!/usr/bin/python

import re
import sys
import os
from subprocess import call, Popen, PIPE
from threading import Thread
from Queue import Queue, Empty

dir_path = os.path.dirname(os.path.realpath(__file__))

#http://eyalarubas.com/python-subproc-nonblock.html
class NonBlockingStreamReader:

    def __init__(self, stream):
        '''
        stream: the stream to read from.
                Usually a process' stdout or stderr.
        '''

        self._s = stream
        self._q = Queue()

        def _populateQueue(stream, queue):
            '''
            Collect lines from 'stream' and put them in 'quque'.
            '''

            while True:
                line = stream.readline()
                if line:
                    queue.put(line)
                else:
                    raise UnexpectedEndOfStream

        self._t = Thread(target = _populateQueue,
                args = (self._s, self._q))
        self._t.daemon = True
        self._t.start() #start collecting lines from the stream

    def readline(self, timeout = None):
        try:
            return self._q.get(block = timeout is not None,
                    timeout = timeout)
        except Empty:
            return None

class UnexpectedEndOfStream(Exception): pass

while True:
	nginx_pid = Popen('pgrep -P $(cat ~/.nginx/pid) | paste -s -d, -', stdout=PIPE, shell=True)
	ln=0
	proc = Popen(['strace', '-p', nginx_pid.stdout.read(), '-e', 'sendfile'], stdout=PIPE, stderr=PIPE)
	nbsr = NonBlockingStreamReader(proc.stderr)
	while True:
		line = nbsr.readline(1);
		if not line:
			print call(['rrdupdate', 'procs/nginx.rrd', '-t', 'out', 'N:0'])
		else:
			ps = re.search('= ([0-9]{1,20})$', line)
			if ps != None:
				print call(['rrdupdate', 'procs/nginx.rrd', '-t', 'out', 'N:' + ps.group(1)])
			
		if ln % 10 == 0:
			print call([dir_path + '/nginx_graph_strace.sh'])
		ln += 1
