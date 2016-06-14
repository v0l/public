# Script to generate protobuf-net class files with attribute flags
# Works with proto2 format only (didn't try any other versions)

import os
import sys

class ProtoClassWriter:
	def __init__(self, dir, namespace):
		self.using = ['System', 'ProtoBuf']
		self.ns = namespace
		self.dir = dir
	
	def FormatCase(self, name):
		return name[0:1].upper() + name[1:]
	
	def CleanEnumVal(self, v):
		return v.strip().replace(';','')
	
	def GetCSType(self, type):
		types = {
			'uint32': 'UInt32',
			'uint64': 'UInt64',
			'bool': 'bool',
			'float': 'float',
			'double': 'double',
			'string': 'string',
			'int64': 'Int64',
			'int32': 'Int32'
		}
		
		if type in types:
			return types[type]
		else:
			#Remove proto namespace
			if '.' in type:
				tn = type.split('.')
				return tn[len(tn)-1]
			else:
				return type

	def WriteFile(self, cls):
		self.c = cls
		self.outFile = open(self.dir + "\\" + self.c.name + ".cs", 'w+')
		
		#Write header part and namespace
		for h in self.using:
			self.outFile.write("using " + h + ";\n")
		
		#write start of namespace
		self.outFile.write("\nnamespace " + self.ns + "\n{\n")
		
		#write class name and proto attribute
		self.outFile.write("\t[ProtoContract]\n\tpublic " + ("enum" if self.c.isenum else "class") + " " + self.c.name + "\n\t{\n")
		
		#write members
		for (k, v) in enumerate(self.c.members):
			if self.c.isenum:
				self.outFile.write(("" if k == 0 else "\n\n") + "\t\t[ProtoEnum]\n\t\t" + self.FormatCase(v.name) + " = " + self.CleanEnumVal(v.type) + ",")
			else:
				self.outFile.write(("" if k == 0 else "\n\n") + "\t\t/// <summary>\n\t\t/// " + v.comments + "\n\t\t/// </summary>\n")
				if v.required:
					self.outFile.write("\t\t[ProtoMember(" + str(k+1) + ", Options = MemberSerializationOptions.Required)]\n\t\tpublic " + self.GetCSType(v.type) + " " + self.FormatCase(v.name) + " { get; set; }")
				else:
					self.outFile.write("\t\t[ProtoMember(" + str(k+1) + ")]\n\t\tpublic " + self.GetCSType(v.type) + " " + self.FormatCase(v.name) + " { get; set; }")
				
		#write end of class
		self.outFile.write("\n\t}")
		
		#write end of namespace
		self.outFile.write("\n}")

class ProtoMemeber:
	def __init__(self, type, name, req, comm):
		self.type = type
		self.name = name
		self.required = req
		self.comments = comm
		
class ProtoClass:
	def __init__(self, name, namespace, isenum):
		self.members = []
		self.name = name
		self.isenum = isenum
		
	def AddMember(self, type, name, req, comm):
		self.members.append(ProtoMemeber(type, name, req, comm))
		
class ProtoParser:
	def __init__(self, dir, ns):
		self.thisClass = None
		self.namespace = ns
		self.outDir = dir
		self.writer = ProtoClassWriter(self.outDir, self.namespace)
		
	def ParseFile(self, path):
		if os.path.exists(path):
			fin = open(path)
			lcom = ""
			for line in fin:
				line = line.strip()
				if line.startswith('message') or line.startswith('enum') and self.thisClass == None:
					typeName = line.split(' ')[1]
					self.thisClass = ProtoClass(typeName, self.namespace, (True if line.startswith('enum') else False))
					print("New message type: " + typeName)
				elif line.startswith('};') and self.thisClass != None:
					#This is the end of a message, write the cs file
					self.writer.WriteFile(self.thisClass)
					self.thisClass = None
				elif self.thisClass != None:
					ls = line.split(' ')
					if self.thisClass.isenum and len(ls) > 1:
						if not line.startswith("//"):
							self.thisClass.AddMember(ls[2], ls[0], False, lcom)
						elif line.startswith("//"):
							lcom = line[2:].strip()
					else:
						if not line.startswith("//") and len(ls) > 3 and ls[0] in { 'repeated', 'optional', 'required' }:
							self.thisClass.AddMember(ls[1], ls[2], (True if ls[0] == 'required' else False), lcom)
							lcom = ""
						elif line.startswith("//"):
							lcom = line[2:].strip()
			fin.close()

args = sys.argv
if len(args) != 3:
	print "Helper script to generate .cs files from .proto files\n"
	print "Usage: " + args[0].split('\\')[-1] + " \"..\ProtoDir\" \"My.NameSpace\""
else:
	#do startup stuff (check folders etc)
	outdir = args[1]
	if not os.path.exists(outdir):
		os.makedirs(outdir)

	pp = ProtoParser(outdir, args[2])
	f = []

	for (dirpath, dirnames, filenames) in os.walk('.'):
		f.extend(filenames)

	for file in filenames:
		if file.endswith('.proto'):
			pp.ParseFile(file)