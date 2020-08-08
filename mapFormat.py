#!/usr/bin/py

import sys
import io

if (len(sys.argv) < 3) :
    print("Usage: mapFormat.py inmap outfile")
    exit(1)
infile = io.open(sys.argv[1], 'r+b')
input = bytearray(infile.read())
infile.close()
outfile = io.open(sys.argv[2], 'w')
outfile.write(u"Tile:\tBase:\tLZ:\t\tSet:\tUse:\tEnd:\n")
lz = 0
for entry in input :
    if (lz != 0) :
        outfile.write(u" " + "{0:#0{1}X}".format(entry,4)[2:])
        lz -= 1
        if (lz == 0) :
            outfile.write(u"\n")
        continue
    if (entry % 2 == 0) :
        outfile.write(u"\t")
    if (entry % 4 == 2) :
        outfile.write(u"\t")
        if (entry & 0b00011000 != 0) :
            outfile.write(u"\t\t")
        else :
            lz = 2
            outfile.write(u"{0:#0{1}X}".format(entry,4)[2:])
            continue
        if (entry & 0b00011000 ^ 0b00001000 != 0) :
            outfile.write(u"\t")
    if (entry == 0x16) :
        outfile.write(u"\t")
    outfile.write(u"{0:#0{1}X}\n".format(entry,4)[2:])
