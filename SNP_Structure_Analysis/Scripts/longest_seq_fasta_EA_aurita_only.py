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
    filtered_records = [record for record in records if record.id.startswith("A_vil_aur")]
    for record in filtered_records:
        name = str(record.id)
        seq = str(record.seq)
        seq_length = len(seq) - seq.count("-")  # calculate the length of the seq
        lengths.append(seq_length)  # append the length to a list
    if lengths:  # Check if there are any sequences that start with "A_vil_aur"
        longest_index = lengths.index(max(lengths))  # identify the position of the longest sequence
        SeqIO.write(filtered_records[longest_index], outname, "fasta")






