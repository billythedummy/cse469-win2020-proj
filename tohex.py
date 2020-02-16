#!/usr/bin/python

import argparse
import os
import subprocess
import re

parser = argparse.ArgumentParser(description='Compiles and converts a C/assembly file to hexcode')
parser.add_argument('fname', metavar='fname', type=str,
                    help='file to convert')
parser.add_argument('--cc', metavar='cc', type=str,
                    help='cross-compiler')
parser.add_argument('--output', metavar='output', type=str,
                    help='file to output')

args = parser.parse_args()
fname = args.fname
basename = os.path.basename(fname).replace(".c", "").replace(".s", "")
fext = fname[-2:]
if fext != ".s" and fext != ".c":
    print("Error: File must be either ASM (.s) or C (.c)")
    exit()

cc = args.cc
if cc is None:
    cc = "arm-none-eabi-gcc"
    print(f"cc not provided, falling back to default of '{cc}'")

outfile = args.output
if outfile is None:
    outfile = f"{basename}.mem"
    print(f"output argument not provided, writing output to '{outfile}''")

asmfname = fname
if fext == ".c":
    subprocess.call([cc, "-S", fname])
    asmfname = f"{basename}.s"

subprocess.call([cc, "-c", asmfname])

split_cc = cc.split("-")
split_cc[-1] = "objdump"
objdump_exec = "-".join(split_cc)
objfname = f"{basename}.o"
dump = subprocess.run([objdump_exec, "-d", objfname], stdout=subprocess.PIPE).stdout.decode("utf-8")
dump = dump.split("\n")

with open(outfile, "w") as f:
    pattern = re.compile("^\s*([0-9A-Fa-f]+\:\s*).*$")
    previous_addr = -4
    for line in dump:
        re_match = pattern.search(line)
        if re_match:
            prefix = re_match.group(1)
            addr = int(f"0x{prefix.strip().replace(':', '')}", 0)
            assert(addr == (previous_addr + 4))
            start_ind = line.find(prefix) + len(prefix)
            remove_pref = line[start_ind:]
            space_ind = remove_pref.find(" ")
            instr = remove_pref[:space_ind]
            for i in range(0, len(instr), 2):
                f.write(f'{instr[i:i+2]}') # no more spaces, memory is in words now
            f.write("\n")
            previous_addr = addr

print("Hexfile written, cleaning up")
print(f"Removing {objfname}...")
subprocess.call(["rm", objfname])
#if fext == ".c":
    #print(f"Removing {asmfname}...")
    #subprocess.call(["rm", asmfname])




