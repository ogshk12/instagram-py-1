#!/usr/bin/python
import sys

print("Patch-Shebang v0.0.1 , A Small Shebang patcher better than sed.")
print("Copyright (C) 2018 Antony Jr.\n")

if len(sys.argv) < 2:
    print("fatal error:: not enough args")
    sys.exit(-1)

in_fp = open(sys.argv[1] , 'r')

Buffer = list()
lineOne = True

for i in in_fp:
    if lineOne:
        lineOne = False
        Buffer.append("#!/usr/bin/python\n")
    else:
        Buffer.append(i)
print("[*] Buffer input file... ")
print("[*] Overwriting original file... ")
in_fp.close()

with open(sys.argv[1] , 'w') as fp:
    for i in Buffer:
        fp.write(i)

print("[+] Patched Successfully!")
print("[+] Exiting... ")
sys.exit(0)
