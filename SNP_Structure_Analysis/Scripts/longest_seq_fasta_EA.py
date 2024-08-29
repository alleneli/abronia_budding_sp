#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import glob
import argparse
from Bio import SeqIO

####### Arguments and help ###########
parser = argparse.ArgumentParser(description="\
Script to subselect the longest sequence from each fasta in the folder \
from where the script is excuted and write each it in a new fasta file \
written by Oscar Vargas oscarmvargas.com\
updated by Eli to fit python3\
")
parser.add_argument("-e", help="file(s) extension, default = fna", default="fna")
parser.add_argument("-o", help="output suffix defaul = longest ", default="longest")
args = parser.parse_args()

pattern = '*.' + args.e
suffix = "." + args.o

files = glob.glob(pattern)

for file in files:
    print("processing " + file)  # Adjusted print statement
    outname = file + suffix
    lengths = []
    records = list(SeqIO.parse(file, "fasta"))
    for record in records:
        name = str(record.id)  # Changed from record.name to record.id
        seq = str(record.seq)
        seq_length = len(seq) - seq.count("-")  # calculate the length of the seq
        lengths.append(seq_length)  # append the length to a list
        # print(name + " has " + str(seq_length) + " nucleotides")  # commented out for brevity
    longest_index = lengths.index(max(lengths))  # identify the position of the longest sequence
    SeqIO.write(records[longest_index], outname, "fasta")





